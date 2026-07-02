import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/presentation/inventory/inventory_task_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('append 与 load 盘点历史', () async {
    await InventoryTaskStorage.append(
      InventoryHistoryEntry(
        completedAt: DateTime(2026, 7, 2, 10, 30),
        locationName: '厨房',
        totalCount: 5,
        confirmedCount: 3,
        adjustedCount: 1,
        skippedCount: 1,
      ),
    );

    final list = await InventoryTaskStorage.load();
    expect(list.length, 1);
    expect(list.first.locationName, '厨房');
    expect(list.first.totalCount, 5);
    expect(list.first.confirmedCount, 3);
  });
}
