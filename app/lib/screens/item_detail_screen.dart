import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/models/item.dart';
import 'package:app/screens/add_item_screen.dart';

/// 物品详情屏幕类，用于查看和编辑物品详细信息
class ItemDetailScreen extends StatefulWidget {
  /// 物品ID
  final int itemId;

  /// 构造函数
  /// [itemId] 要查看的物品ID
  const ItemDetailScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

/// ItemDetailScreen的状态类
class _ItemDetailScreenState extends State<ItemDetailScreen> {
  /// 初始化状态，加载物品详情
  @override
  void initState() {
    super.initState();
    // 使用addPostFrameCallback确保在构建完成后再加载数据，避免setState() during build错误
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);
      itemProvider.getItemDetail(widget.itemId);
      itemProvider.getItemUsageHistory(widget.itemId);
    });
  }

  /// 删除物品方法
  /// 调用itemProvider删除物品，并根据结果显示相应的提示
  void _deleteItem() async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    final success = await itemProvider.deleteItem(widget.itemId);
    if (success) {
      // 删除成功，返回上一页
      Navigator.pop(context);
    } else {
      // 删除失败，显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(itemProvider.errorMessage ?? '删除物品失败')),
      );
    }
  }

  /// 构建UI界面
  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final item = itemProvider.selectedItem;

    // 显示加载指示器
    if (itemProvider.isLoading || item == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('物品详情'),
        centerTitle: true,
        actions: [
          // 编辑按钮
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 导航到编辑屏幕
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddItemScreen(item: item),
                ),
              ).then((value) {
                // 编辑完成后重新加载物品详情和使用历史
                final itemProvider = Provider.of<ItemProvider>(context, listen: false);
                itemProvider.getItemDetail(widget.itemId);
                itemProvider.getItemUsageHistory(widget.itemId);
              });
            },
          ),
          // 删除按钮
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 显示删除确认对话框
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
        child: ListView( // 物品功能列表
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 物品名称
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // 物品描述（如果有）
                    if (item.description != null && item.description!.isNotEmpty)
                      Text('描述: ${item.description}'),
                    const SizedBox(height: 8),
                    // 物品数量和单位
                    Text('数量: ${item.quantity} ${item.unit}'),
                    const SizedBox(height: 8),
                    // 物品分类
                    Text('分类: ${itemProvider.categories.firstWhere((c) => c.id == item.categoryId, orElse: () => Category(id: 0, name: '未知', familyId: 0, createdAt: DateTime.now())).name}'),
                    const SizedBox(height: 8),
                    // 物品位置
                    Text('位置: ${itemProvider.locations.firstWhere((l) => l.id == item.locationId, orElse: () => Location(id: 0, name: '未知', familyId: 0, createdAt: DateTime.now())).name}'),
                    const SizedBox(height: 8),
                    // 物品价格（如果有）
                    if (item.price != null)
                      Text('价格: ¥${item.price}'),
                    const SizedBox(height: 8),
                    // 购买日期（如果有）
                    if (item.purchaseDate != null)
                      Text('购买日期: ${item.purchaseDate!.toString().split(' ')[0]}'),
                    const SizedBox(height: 8),
                    // 过期日期（如果有）
                    if (item.expiryDate != null)
                      Text('过期日期: ${item.expiryDate!.toString().split(' ')[0]}'),
                    const SizedBox(height: 8),
                    // 创建时间
                    Text('创建时间: ${item.createdAt.toString().split(' ')[0]}'),
                  ],
                ),
              ),
            ),
            // 使用历史记录
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '使用历史记录',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (itemProvider.usageHistory.isEmpty)
                      const Text('暂无使用历史记录'),
                    if (itemProvider.usageHistory.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: itemProvider.usageHistory.length,
                        itemBuilder: (context, index) {
                          final history = itemProvider.usageHistory[index];
                          final quantityChange = history.currentQuantity - history.previousQuantity;
                          final changeText = quantityChange > 0 
                              ? '+$quantityChange' 
                              : quantityChange < 0 
                                  ? '$quantityChange' 
                                  : '0';
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      history.action,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      history.createdAt.toString().split(' ')[0],
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('数量变化: '),
                                    Text(
                                      changeText,
                                      style: TextStyle(
                                        color: quantityChange > 0 ? Colors.green : quantityChange < 0 ? Colors.red : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text('当前数量: ${history.currentQuantity}'),
                                  ],
                                ),
                                if (history.description != null && history.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text('备注: ${history.description}'),
                                  ),
                                if (history.userName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text('操作人: ${history.userName}'),
                                  ),
                                if (index < itemProvider.usageHistory.length - 1)
                                  const Divider(),
                              ],
                            ),
                          );
                        },
                      ),
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
