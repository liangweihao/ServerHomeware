import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:drift/drift.dart' show Value;
import '../../data/database/app_database.dart';
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
          // 已存在：如果本地没有图片但服务端有，补充图片
          final preview = serverItem['preview_image']?.toString();
          if (preview != null && preview.isNotEmpty &&
              (existing.images == null || existing.images!.isEmpty)) {
            final updated = existing.copyWith(
              images: Value(jsonEncode([preview])),
              updatedAt: DateTime.now(),
            );
            await _db.updateItem(updated);
            updatedImages++;
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
      name: Value(name),
      brand: json['brand'] != null
          ? Value(json['brand'].toString())
          : const Value.absent(),
      categoryId: Value(_parseId(json['category_id']) ?? 0),
      locationId: json['location_id'] != null
          ? Value(_parseId(json['location_id'])!)
          : const Value.absent(),
      currentQuantity: json['current_quantity'] != null
          ? Value(_parseDouble(json['current_quantity']))
          : const Value(1),
      purchaseQuantity: const Value(1), // 列表接口无此字段，用默认值
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
      // 以下字段列表接口不返回或无对应列，设为 absent
      specification: const Value.absent(),
      barcode: const Value.absent(),
      purchasePrice: const Value.absent(),
      purchaseDate: const Value.absent(),
      purchaseChannel: const Value.absent(),
      productionDate: const Value.absent(),
      shelfLifeDays: const Value.absent(),
      openedDate: const Value.absent(),
      afterOpenDays: const Value.absent(),
      warrantyDate: const Value.absent(),
      notes: const Value.absent(),
      avgDailyConsumption: const Value.absent(),
      predictedEmptyDate: const Value.absent(),
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
}
