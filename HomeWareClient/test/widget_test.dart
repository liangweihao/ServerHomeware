import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/events/item_event_bus.dart';
import 'package:home_stock/core/utils/search_utils.dart';
import 'package:home_stock/data/database/app_database.dart';

/// 基础单元测试入口 — 替代默认 counter 模板
void main() {
  test('ItemEventBus smoke', () {
    final bus = ItemEventBus();
    bus.notifyCreated(itemId: 1);
    expect(bus.state, 1);
  });

  test('search utils smoke', () {
    final item = Item(
      id: 1,
      name: '测试',
      categoryId: 1,
      purchaseQuantity: 1,
      packageQuantity: 1,
      currentQuantity: 1,
      unit: '件',
      safetyStock: 1,
      expiryAlertDays: 3,
      stockAlert: true,
      status: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final results = filterItemsByQuery(
      items: [item],
      locationNameByItemId: const {},
      query: '测试',
    );
    expect(results.length, 1);
  });
}
