import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/item_service.dart';
import '../../core/utils/item_image_storage.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

/// 物品详情聚合数据（本地库 + 服务端图片）
class ItemDetailData {
  final Item item;
  final Category? category;
  final Category? parentCategory;
  final String? locationPath;
  final List<UsageRecord> recentRecords;
  /// 可展示的图片 URL（优先服务端，已 resolve 为完整地址）
  final List<String> imageUrls;
  /// 存放位置参考照片
  final List<String> locationImageUrls;

  const ItemDetailData({
    required this.item,
    this.category,
    this.parentCategory,
    this.locationPath,
    required this.recentRecords,
    this.imageUrls = const [],
    this.locationImageUrls = const [],
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

  // 优先从服务端拉取图片列表
  List<String> imageUrls = [];
  try {
    final itemService = ItemService();
    final remote = await itemService.getItemDetail(itemId: id);
    if (remote.code == 200 && remote.data != null) {
      final images = remote.data!['images'] as List<dynamic>?;
      imageUrls = ItemImageStorage.urlsFromServerImages(images);
      debugPrint('[ItemDetailProvider] INFO: 服务端图片 ${imageUrls.length} 张');
    } else {
      debugPrint(
        '[ItemDetailProvider] WARN: 服务端详情失败 code=${remote.code}，使用本地图片',
      );
    }
  } catch (e) {
    debugPrint('[ItemDetailProvider] WARN: 拉取服务端图片异常 $e');
  }

  if (imageUrls.isEmpty) {
    imageUrls = ItemImageStorage.resolveDisplaySources(item.images);
  }

  // 位置参考照片（从本地 images 字段解析 __loc__: 前缀）
  final locationImageUrls = ItemImageStorage.resolveLocationDisplaySources(item.images);

  debugPrint('[ItemDetailProvider] INFO: 加载物品详情 id=$id name=${item.name} '
      'images=${imageUrls.length} locPhotos=${locationImageUrls.length}');
  return ItemDetailData(
    item: item,
    category: category,
    parentCategory: parentCategory,
    locationPath: locationPath,
    recentRecords: recentRecords,
    imageUrls: imageUrls,
    locationImageUrls: locationImageUrls,
  );
});
