import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show debugPrint;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/item_service.dart';
import '../../core/utils/item_api_id.dart';
import '../../core/utils/item_image_storage.dart';
import '../../core/utils/item_route_resolver.dart';
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
  /// 存放位置参考照片（旧：从 item.images 解析 __loc__:）
  final List<String> locationImageUrls;
  /// 位置自带说明照片（新：从 Location.images 读取）
  final List<String> locationPhotoUrls;

  const ItemDetailData({
    required this.item,
    this.category,
    this.parentCategory,
    this.locationPath,
    required this.recentRecords,
    this.imageUrls = const [],
    this.locationImageUrls = const [],
    this.locationPhotoUrls = const [],
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

  final localId = await ItemRouteResolver.resolveLocalId(db, id);
  if (localId == null) {
    debugPrint('[ItemDetailProvider] WARN: 无法解析物品 routeId=$id');
    return null;
  }

  final item = await db.getItemById(localId);
  if (item == null) {
    debugPrint('[ItemDetailProvider] WARN: 物品不存在 localId=$localId routeId=$id');
    return null;
  }

  final category = await db.getCategoryById(item.categoryId);
  Category? parentCategory;
  if (category?.parentId != null) {
    parentCategory = await db.getCategoryById(category!.parentId!);
  }

  String? locationPath;
  String? locationImages; // 位置自带说明图片 JSON
  if (item.locationId != null) {
    final location = await db.getLocationById(item.locationId!);
    locationPath = location?.fullPath;
    locationImages = location?.images;
  }

  final recentRecords = await db.getUsageRecordsByItem(localId, limit: 5);

  // 优先从服务端拉取最新数据（图片 + 关键字段纠正列表同步默认值问题）
  List<String> imageUrls = [];
  List<String> serverLocationUrls = [];
  Item updatedItem = item;
  try {
    final itemService = ItemService();
    final remote = await itemService.getItemDetail(itemId: item.serverApiId);
    if (remote.code == 200 && remote.data != null) {
      final data = remote.data!;
      final images = data['images'] as List<dynamic>?;
      final parsed = ItemImageStorage.parseServerImages(images);
      imageUrls = parsed.itemUrls;
      serverLocationUrls = parsed.locationUrls;
      debugPrint('[ItemDetailProvider] INFO: 服务端物品图 ${imageUrls.length} 张, '
          '位置图 ${serverLocationUrls.length} 张');

      // 用服务端数据纠正本地可能被列表同步覆盖的关键字段
      final serverPurchaseQty = data['purchase_quantity'];
      final serverCurrentQty = data['current_quantity'];
      final serverPackageUnit = data['package_unit'];
      final serverPackageQty = data['package_quantity'];
      final serverUnit = data['unit'];
      final serverSafetyStock = data['safety_stock'];
      final serverStatus = data['status'];
      final serverPurchasePrice = data['purchase_price'];
      final serverSalePrice = data['sale_price'];
      final serverSupplier = data['supplier'];

      final validPaths = parsed.storagePaths;
      final needsFieldUpdate = serverPurchaseQty != null ||
          serverCurrentQty != null ||
          serverPurchasePrice != null ||
          serverSalePrice != null ||
          serverSupplier != null;
      final needsImageUpdate = validPaths.isNotEmpty;

      if (needsFieldUpdate || needsImageUpdate) {
        updatedItem = updatedItem.copyWith(
          purchaseQuantity: serverPurchaseQty != null
              ? (serverPurchaseQty as num).toInt()
              : null,
          currentQuantity: serverCurrentQty != null
              ? (serverCurrentQty as num).toDouble()
              : null,
          packageUnit: serverPackageUnit != null
              ? Value<String?>(serverPackageUnit.toString())
              : const Value.absent(),
          packageQuantity: serverPackageQty != null
              ? (serverPackageQty as num).toInt()
              : null,
          unit: serverUnit != null ? serverUnit.toString() : null,
          safetyStock: serverSafetyStock != null
              ? (serverSafetyStock as num).toDouble()
              : null,
          status: serverStatus != null ? (serverStatus as num).toInt() : null,
          purchasePrice: serverPurchasePrice != null
              ? Value((serverPurchasePrice as num).toDouble())
              : const Value.absent(),
          salePrice: serverSalePrice != null
              ? Value((serverSalePrice as num).toDouble())
              : const Value.absent(),
          supplier: serverSupplier != null
              ? Value(serverSupplier.toString())
              : const Value.absent(),
          images: needsImageUpdate
              ? Value(jsonEncode(validPaths))
              : const Value.absent(),
        );
        await db.updateItem(updatedItem);
        if (needsImageUpdate) {
          debugPrint('[ItemDetailProvider] INFO: 已用服务端有效图片更新本地 images');
        }
        debugPrint('[ItemDetailProvider] INFO: 已用服务端数据纠正本地字段');
      }
    } else {
      debugPrint(
        '[ItemDetailProvider] WARN: 服务端详情失败 code=${remote.code}，使用本地图片',
      );
    }
  } catch (e) {
    debugPrint('[ItemDetailProvider] WARN: 拉取服务端数据异常 $e');
  }

  if (imageUrls.isEmpty) {
    imageUrls = ItemImageStorage.resolveDisplaySources(item.images);
  }

  // 位置参考照片：服务端位置图 + 本地 __loc__: 照片（去重）
  final localLocationUrls = ItemImageStorage.resolveLocationDisplaySources(item.images);
  final locationImageUrls = <String>{
    ...serverLocationUrls,
    ...localLocationUrls,
  }.toList();
  // 位置自带照片（从 Location.images 读取 — 新方案）
  final locationPhotoUrls = ItemImageStorage.resolveDisplaySources(locationImages);

  debugPrint('[ItemDetailProvider] INFO: 加载物品详情 routeId=$id localId=$localId '
      'name=${item.name} images=${imageUrls.length} locPhotos=${locationImageUrls.length}');
  return ItemDetailData(
    item: updatedItem,
    category: category,
    parentCategory: parentCategory,
    locationPath: locationPath,
    recentRecords: recentRecords,
    imageUrls: imageUrls,
    locationImageUrls: locationImageUrls,
    locationPhotoUrls: locationPhotoUrls,
  );
});
