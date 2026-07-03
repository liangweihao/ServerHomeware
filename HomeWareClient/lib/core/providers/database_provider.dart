import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../events/item_event_bus.dart';

// 数据库单例 Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

// 分类相关 Providers
final topLevelCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTopLevelCategories();
});

// 位置相关 Providers
final topLevelLocationsProvider = FutureProvider<List<Location>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTopLevelLocations();
});

// 物品列表 Provider
final allItemsProvider = FutureProvider<List<Item>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllItems();
});

// 单个物品 Provider
final itemByIdProvider = FutureProvider.family<Item?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.getItemById(id);
});

// 提醒数量（四类合计，兼容旧引用；Badge 请用 unreadAlertCountProvider）
final alertCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAlertCount();
});

// 位置详情 Provider
final locationByIdProvider = FutureProvider.family<Location?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.getLocationById(id);
});

// 子位置列表 Provider
final childLocationsProvider = FutureProvider.family<List<Location>, int>((ref, parentId) async {
  final db = ref.watch(databaseProvider);
  return db.getChildLocations(parentId);
});

// 位置下物品列表 Provider（仅当前层）
final itemsInLocationProvider = FutureProvider.family<List<Item>, int>((ref, locationId) async {
  final db = ref.watch(databaseProvider);
  return db.getItemsInLocation(locationId);
});

/// 位置及子位置下使用中物品 — 场景入口 / 管管查询对齐
final itemsInLocationTreeProvider =
    FutureProvider.family<List<Item>, int>((ref, locationId) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  return db.getItemsInLocationTree(locationId);
});
