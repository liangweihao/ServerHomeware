import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/models/item.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;

  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      itemProvider.getItemDetail(widget.itemId);
    });
  }

  void _deleteItem() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final success = await itemProvider.deleteItem(widget.itemId);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(itemProvider.errorMessage ?? '删除物品失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final item = itemProvider.selectedItem;

    if (itemProvider.isLoading || item == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('物品详情'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 导航到编辑屏幕
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('删除物品'),
                    content: const Text('确定要删除这个物品吗？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteItem();
                        },
                        child: const Text('删除'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (item.description != null && item.description!.isNotEmpty)
                      Text('描述: ${item.description}'),
                    const SizedBox(height: 8),
                    Text('数量: ${item.quantity} ${item.unit}'),
                    const SizedBox(height: 8),
                    Text('分类: ${itemProvider.categories.firstWhere((c) => c.id == item.categoryId, orElse: () => Category(id: 0, name: '未知', familyId: 0, createdAt: DateTime.now())).name}'),
                    const SizedBox(height: 8),
                    Text('位置: ${itemProvider.locations.firstWhere((l) => l.id == item.locationId, orElse: () => Location(id: 0, name: '未知', familyId: 0, createdAt: DateTime.now())).name}'),
                    const SizedBox(height: 8),
                    if (item.price != null)
                      Text('价格: ¥${item.price}'),
                    const SizedBox(height: 8),
                    if (item.expiryDate != null)
                      Text('过期日期: ${item.expiryDate!.toString().split(' ')[0]}'),
                    const SizedBox(height: 8),
                    if (item.purchaseDate != null)
                      Text('购买日期: ${item.purchaseDate!.toString().split(' ')[0]}'),
                    const SizedBox(height: 8),
                    Text('创建时间: ${item.createdAt.toString().split(' ')[0]}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
