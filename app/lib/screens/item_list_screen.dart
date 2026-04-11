import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/screens/add_item_screen.dart';
import 'package:app/screens/item_detail_screen.dart';
import 'package:app/models/family.dart';

/// 物品列表屏幕类
class ItemListScreen extends StatefulWidget {
  /// 构造函数
  const ItemListScreen({Key? key}) : super(key: key);

  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

/// 物品列表屏幕状态类
class _ItemListScreenState extends State<ItemListScreen> {
  /// 上次选中的家庭ID
  int? _lastSelectedFamilyId;

  @override
  void initState() {
    super.initState();
    // 延迟加载物品数据，确保Widget已经构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadItems();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 监听家庭列表变化，当选中的家庭变更时重新加载数据
    final familyProvider = Provider.of<FamilyProvider>(context);
    final selectedFamily = familyProvider.families.cast<Family?>().firstWhere(
      (family) => family?.isSelected ?? false,
      orElse: () => null,
    );
    
    if (selectedFamily?.id != _lastSelectedFamilyId) {
      _lastSelectedFamilyId = selectedFamily?.id;
      // 延迟加载数据，避免在构建过程中调用 notifyListeners()
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadItems();
      });
    }
  }

  /// 加载物品数据
  /// 从选中的家庭中获取物品、分类和位置数据
  void _loadItems() {
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    // 从家庭列表中获取选中的家庭
    final selectedFamily = familyProvider.families.cast<Family?>().firstWhere(
      (family) => family?.isSelected ?? false,
      orElse: () => null,
    );
    if (selectedFamily != null) {
      itemProvider.getItems(selectedFamily.id);
      itemProvider.getCategories(selectedFamily.id);
      itemProvider.getLocations(selectedFamily.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    // 从家庭列表中获取选中的家庭
    final selectedFamily = familyProvider.families.cast<Family?>().firstWhere(
      (family) => family?.isSelected ?? false,
      orElse: () => null,
    );

    // 如果没有选择家庭，显示提示信息
    if (selectedFamily == null) {
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
      // 物品列表
      body: itemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemProvider.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 20),
                      const Text('暂无物品', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text('点击下方按钮添加第一个物品', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddItemScreen()),
                          );
                        },
                        child: const Text('立即添加'),
                      ),
                    ],
                  ),
                )
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
