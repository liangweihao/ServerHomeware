import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:drift/drift.dart' show Value;
import '../../data/database/app_database.dart';
import '../utils/item_image_storage.dart';
import '../utils/item_server_mapper.dart';
import 'item_service.dart';

/// 物品服务端 → 本地数据库同步服务
///
/// 用于：
/// - App 启动时从服务端拉取最新物品数据
/// - 缓存清理后恢复物品
/// - 多设备间数据同步
class ItemSyncService {
  final AppDatabase _db;
  final ItemService _itemService;

  ItemSyncService(this._db) : _itemService = ItemService();

  /// 从服务端同步物品到本地数据库
  ///
  /// - 本地已存在的物品（同 ID）：跳过（避免覆盖本地更完整的数据）
  /// - 本地不存在的物品：插入（覆盖缓存清理/新设备登录场景）
  ///
  /// 返回同步后本地物品总数
  Future<int> syncFromServer() async {
    try {
      final serverItems = await _itemService.getAllItemsFromServer();
      if (serverItems.isEmpty) {
        debugPrint('[ItemSync] INFO: 服务端无物品，跳过同步');
        return await _countLocalItems();
      }

      int inserted = 0;
      int skipped = 0;

      int updatedImages = 0;

      for (final serverItem in serverItems) {
        final id = _parseId(serverItem['id']);
        if (id == null) continue;

        // 检查本地是否已存在
        final existing = await _db.getItemById(id);
        if (existing != null) {
          await _db.ensureItemServerItemId(id, id);
          // 已存在：用服务端数据更新核心字段（封面图、数量、单位等）
          final preview = serverItem['preview_image']?.toString();
          final currentQty = serverItem['current_quantity'];
          final purchaseQty = serverItem['purchase_quantity'];
          final pkgUnit = serverItem['package_unit'];
          final pkgQty = serverItem['package_quantity'];
          final srvUnit = serverItem['unit'];
          final srvStatus = serverItem['status'];
          final srvExpiry = serverItem['expiry_date'];
          final srvAvgDaily = serverItem['avg_daily_consumption'];
          final srvPredictedEmpty = serverItem['predicted_empty_date'];

          final shouldUpdatePreview = preview != null &&
              preview.isNotEmpty &&
              _shouldUpdatePreviewImage(preview, existing.images);

          final needsUpdate = currentQty != null ||
              purchaseQty != null ||
              srvAvgDaily != null ||
              srvPredictedEmpty != null ||
              shouldUpdatePreview;

          if (needsUpdate) {
            final updated = existing.copyWith(
              currentQuantity: currentQty != null
                  ? _parseDouble(currentQty)
                  : null,
              purchaseQuantity: purchaseQty != null
                  ? _parseInt(purchaseQty)
                  : null,
              packageUnit: pkgUnit != null
                  ? Value<String?>(pkgUnit.toString())
                  : const Value.absent(),
              packageQuantity: pkgQty != null
                  ? _parseInt(pkgQty)
                  : null,
              unit: srvUnit != null
                  ? srvUnit.toString()
                  : null,
              status: srvStatus != null
                  ? _parseInt(srvStatus)
                  : null,
              expiryDate: srvExpiry != null
                  ? Value(DateTime.tryParse(srvExpiry.toString()))
                  : const Value.absent(),
              avgDailyConsumption:
                  ItemServerMapper.avgDailyConsumptionFromJson(serverItem),
              predictedEmptyDate:
                  ItemServerMapper.predictedEmptyDateFromJson(serverItem),
              images: shouldUpdatePreview
                  ? Value(jsonEncode([preview]))
                  : const Value.absent(),
              updatedAt: DateTime.now(),
            );
            await _db.updateItem(updated);
            if (shouldUpdatePreview) {
              updatedImages++;
            }
          }
          skipped++;
          continue;
        }

        // 本地不存在，从服务端恢复
        try {
          await _db.insertItem(_serverItemToCompanion(serverItem));
          inserted++;
        } catch (e) {
          debugPrint('[ItemSync] WARN: 插入物品 id=$id 失败: $e');
        }
      }

      final total = await _countLocalItems();
      debugPrint(
        '[ItemSync] INFO: 同步完成 — 新增 $inserted 件, '
        '已存在 $skipped 件, 补图 $updatedImages 件, 本地共 $total 件',
      );
      return total;
    } catch (e) {
      debugPrint('[ItemSync] ERROR: 同步失败 — $e');
      return await _countLocalItems();
    }
  }

  /// 将服务端物品 JSON 转为 Drift InsertCompanion
  ItemsCompanion _serverItemToCompanion(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '未知物品';

    return ItemsCompanion(
      id: Value(_parseId(json['id']) ?? 0),
      serverItemId: Value(_parseId(json['id']) ?? 0),
      name: Value(name),
      brand: json['brand'] != null
          ? Value(json['brand'].toString())
          : const Value.absent(),
      categoryId: Value(_parseId(json['category_id']) ?? 0),
      locationId: json['location_id'] != null
          ? Value(_parseId(json['location_id'])!)
          : const Value.absent(),
      containerName: json['container_name'] != null
          ? Value(json['container_name'].toString())
          : const Value.absent(),
      currentQuantity: json['current_quantity'] != null
          ? Value(_parseDouble(json['current_quantity']))
          : const Value(1),
      purchaseQuantity: json['purchase_quantity'] != null
          ? Value(_parseInt(json['purchase_quantity']))
          : const Value(1),
      packageUnit: json['package_unit'] != null
          ? Value(json['package_unit'].toString())
          : const Value.absent(),
      packageQuantity: json['package_quantity'] != null
          ? Value(_parseInt(json['package_quantity']))
          : const Value(1),
      unit: json['unit'] != null
          ? Value(json['unit'].toString())
          : const Value('件'),
      safetyStock: const Value(1),
      status: json['status'] != null
          ? Value(_parseInt(json['status']))
          : const Value(0),
      expiryDate: json['expiry_date'] != null
          ? Value(DateTime.tryParse(json['expiry_date'].toString()))
          : const Value.absent(),
      expiryAlertDays: const Value(3),
      stockAlert: const Value(true),
      avgDailyConsumption:
          ItemServerMapper.avgDailyConsumptionFromJson(json),
      predictedEmptyDate:
          ItemServerMapper.predictedEmptyDateFromJson(json),
      // 以下字段列表接口不返回或无对应列，设为 absent
      specification: const Value.absent(),
      barcode: const Value.absent(),
      purchasePrice: json['purchase_price'] != null
          ? Value(_parseDouble(json['purchase_price']))
          : const Value.absent(),
      salePrice: json['sale_price'] != null
          ? Value(_parseDouble(json['sale_price']))
          : const Value.absent(),
      supplier: json['supplier'] != null
          ? Value(json['supplier'].toString())
          : const Value.absent(),
      purchaseDate: const Value.absent(),
      purchaseChannel: const Value.absent(),
      productionDate: const Value.absent(),
      shelfLifeDays: const Value.absent(),
      openedDate: const Value.absent(),
      afterOpenDays: const Value.absent(),
      warrantyDate: const Value.absent(),
      notes: const Value.absent(),
      // 如果有预览图，以 JSON 数组格式存入本地
      images: json['preview_image'] != null
          ? Value(jsonEncode([json['preview_image']]))
          : const Value.absent(),
    );
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  Future<int> _countLocalItems() async {
    final items = await _db.getAllItems();
    return items.length;
  }

  /// 服务端 preview_image 比本地封面更新时覆盖（修复历史失效 URL）
  bool _shouldUpdatePreviewImage(String serverPreview, String? localImagesJson) {
    if (localImagesJson == null || localImagesJson.isEmpty) return true;

    final serverDate = ItemImageStorage.extractUploadDate(serverPreview);
    final localPaths = ItemImageStorage.decodeItemImages(localImagesJson);
    if (localPaths.isEmpty) return true;

    String? localNewest;
    for (final path in localPaths) {
      final d = ItemImageStorage.extractUploadDate(path);
      if (d != null && (localNewest == null || d.compareTo(localNewest) > 0)) {
        localNewest = d;
      }
    }

    if (serverDate == null || localNewest == null) {
      return serverPreview != localPaths.first;
    }
    return serverDate.compareTo(localNewest) >= 0;
  }
}
