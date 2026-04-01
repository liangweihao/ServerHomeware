import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/screens/category_management_screen.dart';
import 'package:app/screens/location_management_screen.dart';

/// 库存屏幕类，用于显示库存预警、报表和采购建议
class InventoryScreen extends StatefulWidget {
  /// 构造函数
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

/// InventoryScreen的状态类
class _InventoryScreenState extends State<InventoryScreen> {
  /// 当前选中的标签页索引
  int _currentTab = 0;

  /// 初始化状态，加载库存数据
  @override
  void initState() {
    super.initState();
    // 使用addPostFrameCallback确保在构建完成后再加载数据，避免setState() during build错误
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventoryData();
    });
  }

  /// 加载库存数据
  /// 包括库存预警、库存报表和采购建议
  void _loadInventoryData() {
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    if (familyProvider.selectedFamily != null) {
      itemProvider.getInventoryAlerts(familyProvider.selectedFamily!.id);
      itemProvider.getInventoryReport(familyProvider.selectedFamily!.id);
      itemProvider.getPurchaseSuggestions(familyProvider.selectedFamily!.id);
    }
  }

  /// 构建UI界面
  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    // 未选择家庭时显示提示
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
      body: DefaultTabController(
        length: 5, // 五个标签页
        initialIndex: _currentTab,
        child: Column(
          children: [
            // 标签栏
            const TabBar(
              tabs: [
                Tab(text: '库存预警'),
                Tab(text: '库存报表'),
                Tab(text: '采购建议'),
                Tab(text: '分类管理'),
                Tab(text: '位置管理'),
              ],
            ),
            // 标签内容
            Expanded(
              child: TabBarView(
                children: [
                  // 库存预警标签页
                  itemProvider.isLoading
                      ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
                      : itemProvider.inventoryAlerts.isEmpty
                          ? const Center(child: Text('暂无库存预警')) // 无预警时显示提示
                          : ListView.builder(
                              itemCount: itemProvider.inventoryAlerts.length,
                              itemBuilder: (context, index) {
                                final alert = itemProvider.inventoryAlerts[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(alert['item_name']),
                                    subtitle: Text(alert['message']),
                                    trailing: const Icon(Icons.warning, color: Colors.red),
                                  ),
                                );
                              },
                            ),
                  // 库存报表标签页
                  itemProvider.isLoading
                      ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('总物品数: ${itemProvider.inventoryReport['total_items'] ?? 0}'),
                              const SizedBox(height: 8),
                              Text('总价值: ¥${itemProvider.inventoryReport['total_value'] ?? 0}'),
                              const SizedBox(height: 8),
                              Text('即将过期: ${itemProvider.inventoryReport['expiring_soon'] ?? 0}'),
                              const SizedBox(height: 8),
                              Text('库存不足: ${itemProvider.inventoryReport['low_stock'] ?? 0}'),
                            ],
                          ),
                        ),
                  // 采购建议标签页
                  itemProvider.isLoading
                      ? const Center(child: CircularProgressIndicator()) // 显示加载指示器
                      : itemProvider.purchaseSuggestions.isEmpty
                          ? const Center(child: Text('暂无采购建议')) // 无建议时显示提示
                          : ListView.builder(
                              itemCount: itemProvider.purchaseSuggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = itemProvider.purchaseSuggestions[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(suggestion['item_name']),
                                    subtitle: Text('建议购买: ${suggestion['suggested_quantity']} ${suggestion['unit']}'),
                                    trailing: const Icon(Icons.shopping_cart),
                                  ),
                                );
                              },
                            ),
                  // 分类管理标签页
                  CategoryManagementScreen(familyId: familyProvider.selectedFamily!.id),
                  // 位置管理标签页
                  LocationManagementScreen(familyId: familyProvider.selectedFamily!.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
