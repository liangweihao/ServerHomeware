import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/guanguan_panel_builder.dart';
import 'package:home_stock/core/assistant/guanguan_panel_models.dart';
import 'package:home_stock/data/database/app_database.dart';

void main() {
  final now = DateTime(2026, 7, 4, 12);

  Item item({
    required int id,
    required String name,
    DateTime? expiry,
    double qty = 2,
    double safety = 1,
    int? locationId,
  }) {
    return Item(
      id: id,
      name: name,
      categoryId: 1,
      purchaseQuantity: 1,
      packageQuantity: 1,
      currentQuantity: qty,
      unit: '件',
      safetyStock: safety,
      expiryAlertDays: 3,
      stockAlert: true,
      status: 0,
      locationId: locationId,
      expiryDate: expiry,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('GuanguanPanelBuilder.buildTasks', () {
    test('按紧急度取 Top3', () {
      final tasks = GuanguanPanelBuilder.buildTasks([
        item(
          id: 1,
          name: '过期品',
          expiry: now.subtract(const Duration(days: 1)),
        ),
        item(
          id: 2,
          name: '临期品',
          expiry: now.add(const Duration(days: 2)),
        ),
        item(id: 3, name: '低库存', qty: 0.5, safety: 2),
        item(id: 4, name: '正常', expiry: now.add(const Duration(days: 60))),
      ]);
      expect(tasks.length, 3);
      expect(tasks.first.itemName, '过期品');
    });
  });

  group('GuanguanPanelBuilder.buildCollaborationQuip', () {
    test('录入与消耗不同人', () {
      final q = GuanguanPanelBuilder.buildCollaborationQuip(members: [
        (name: '妈妈', record: 5, consume: 1),
        (name: '爸爸', record: 1, consume: 4),
      ]);
      expect(q, contains('妈妈'));
      expect(q, contains('爸爸'));
    });
  });

  group('GuanguanPanelBuilder.buildSpaceProficiency', () {
    test('7 日动作换算等级', () {
      final prof = GuanguanPanelBuilder.buildSpaceProficiency(
        spaceName: '厨房',
        spaceRootLocationId: 1,
        allItems: [item(id: 1, name: '盐', locationId: 2)],
        recentRecords: [
          UsageRecord(
            id: 1,
            itemId: 1,
            type: 1,
            quantity: 1,
            remainingQuantity: 1,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
        ],
        locationById: {
          1: Location(
            id: 1,
            name: '厨房',
            level: 1,
            fullPath: '厨房',
            sortOrder: 0,
            createdAt: now,
          ),
          2: Location(
            id: 2,
            name: '冰箱',
            parentId: 1,
            level: 2,
            fullPath: '厨房/冰箱',
            sortOrder: 0,
            createdAt: now,
          ),
        },
        now: now,
      );
      expect(prof.level, 1);
      expect(prof.recentActions, 1);
    });
  });
}
