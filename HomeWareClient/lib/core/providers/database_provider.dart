import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';

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

// 提醒数量 Provider
final alertCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAlertCount();
});
