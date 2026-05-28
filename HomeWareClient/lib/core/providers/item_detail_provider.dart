import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

/// 物品详情聚合数据（本地库）
class ItemDetailData {
  final Item item;
  final Category? category;
  final Category? parentCategory;
  final String? locationPath;
  final List<UsageRecord> recentRecords;

  const ItemDetailData({
    required this.item,
    this.category,
    this.parentCategory,
    this.locationPath,
    required this.recentRecords,
  });

  /// 分类展示：父级 · 子级 或单级名称
  String get categoryLabel {
    if (parentCategory != null && category != null) {
      return '${parentCategory!.name} · ${category!.name}';
    }
    return category?.name ?? '未分类';
  }
}

/// 物品详情 Provider（按物品 ID）
final itemDetailProvider =
    FutureProvider.family<ItemDetailData?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final item = await db.getItemById(id);
  if (item == null) {
    debugPrint('[ItemDetailProvider] WARN: 物品不存在 id=$id');
    return null;
  }

  final category = await db.getCategoryById(item.categoryId);
  Category? parentCategory;
  if (category?.parentId != null) {
    parentCategory = await db.getCategoryById(category!.parentId!);
  }

  String? locationPath;
  if (item.locationId != null) {
    final location = await db.getLocationById(item.locationId!);
    locationPath = location?.fullPath;
  }

  final recentRecords = await db.getUsageRecordsByItem(id, limit: 5);

  debugPrint('[ItemDetailProvider] INFO: 加载物品详情 id=$id name=${item.name}');
  return ItemDetailData(
    item: item,
    category: category,
    parentCategory: parentCategory,
    locationPath: locationPath,
    recentRecords: recentRecords,
  );
});
