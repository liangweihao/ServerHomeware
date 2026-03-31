import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/screens/add_item_screen.dart';
import 'package:app/screens/item_detail_screen.dart';

/// 物品列表屏幕类
class ItemListScreen extends StatefulWidget {
  /// 构造函数
  const ItemListScreen({Key? key}) : super(key: key);

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

/// 物品列表屏幕状态类
class _ItemListScreenState extends State<ItemListScreen> {
  @override
  void initState() {
    super.initState();
    // 延迟加载物品数据，确保Widget已经构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  /// 加载物品数据
  /// 从选中的家庭中获取物品、分类和位置数据
  void _loadItems() {
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    if (familyProvider.selectedFamily != null) {
      itemProvider.getItems(familyProvider.selectedFamily!.id);
      itemProvider.getCategories(familyProvider.selectedFamily!.id);
      itemProvider.getLocations(familyProvider.selectedFamily!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    // 如果没有选择家庭，显示提示信息
    if (familyProvider.selectedFamily == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('请先选择一个家庭'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/family');
              },
              child: const Text('去选择家庭'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      // 添加物品的浮动按钮
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      // 物品列表
      body: itemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: itemProvider.items.length,
              itemBuilder: (context, index) {
                final item = itemProvider.items[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('数量: ${item.quantity} ${item.unit}'),
                  trailing: item.expiryDate != null
                      ? Text('过期: ${item.expiryDate!.toString().split(' ')[0]}')
                      : null,
                  onTap: () {
                    // 点击跳转到物品详情页
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(itemId: item.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
