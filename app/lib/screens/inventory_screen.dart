import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/providers/item_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInventoryData();
    });
  }

  void _loadInventoryData() {
    final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);
    if (familyProvider.selectedFamily != null) {
      itemProvider.getInventoryAlerts(familyProvider.selectedFamily!.id);
      itemProvider.getInventoryReport(familyProvider.selectedFamily!.id);
      itemProvider.getPurchaseSuggestions(familyProvider.selectedFamily!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyProvider = Provider.of<FamilyProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

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
        length: 3,
        initialIndex: _currentTab,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '库存预警'),
                Tab(text: '库存报表'),
                Tab(text: '采购建议'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // 库存预警
                  itemProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<List<dynamic>>(
                          future: itemProvider.getInventoryAlerts(familyProvider.selectedFamily!.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('获取预警失败: ${snapshot.error}'));
                            }
                            final alerts = snapshot.data ?? [];
                            if (alerts.isEmpty) {
                              return const Center(child: Text('暂无库存预警'));
                            }
                            return ListView.builder(
                              itemCount: alerts.length,
                              itemBuilder: (context, index) {
                                final alert = alerts[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(alert['item_name']),
                                    subtitle: Text(alert['message']),
                                    trailing: const Icon(Icons.warning, color: Colors.red),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  // 库存报表
                  itemProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<Map<String, dynamic>>(
                          future: itemProvider.getInventoryReport(familyProvider.selectedFamily!.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('获取报表失败: ${snapshot.error}'));
                            }
                            final report = snapshot.data ?? {};
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('总物品数: ${report['total_items'] ?? 0}'),
                                  const SizedBox(height: 8),
                                  Text('总价值: ¥${report['total_value'] ?? 0}'),
                                  const SizedBox(height: 8),
                                  Text('即将过期: ${report['expiring_soon'] ?? 0}'),
                                  const SizedBox(height: 8),
                                  Text('库存不足: ${report['low_stock'] ?? 0}'),
                                ],
                              ),
                            );
                          },
                        ),
                  // 采购建议
                  itemProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FutureBuilder<List<dynamic>>(
                          future: itemProvider.getPurchaseSuggestions(familyProvider.selectedFamily!.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('获取建议失败: ${snapshot.error}'));
                            }
                            final suggestions = snapshot.data ?? [];
                            if (suggestions.isEmpty) {
                              return const Center(child: Text('暂无采购建议'));
                            }
                            return ListView.builder(
                              itemCount: suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = suggestions[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(suggestion['item_name']),
                                    subtitle: Text('建议购买: ${suggestion['suggested_quantity']} ${suggestion['unit']}'),
                                    trailing: const Icon(Icons.shopping_cart),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
