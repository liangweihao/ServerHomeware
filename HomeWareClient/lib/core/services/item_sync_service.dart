import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:drift/drift.dart' show Value;
import '../../data/database/app_database.dart';
import '../utils/item_image_storage.dart';
import '../utils/item_server_mapper.dart';
import 'item_deleted_registry.dart';
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

  /// 问管管跳转详情 — 确保服务端物品在本地 Drift 存在，返回本地 id
  Future<int?> ensureLocalByServerId(int serverItemId) async {
    if (serverItemId <= 0) return null;

    if (await ItemDeletedRegistry.isDeleted(serverItemId)) {
      debugPrint(
        '[ItemSync] WARN: 物品已被用户删除，不恢复 serverId=$serverItemId',
      );
      return null;
    }

    final mapped = await _db.getItemByServerItemId(serverItemId);
    if (mapped != null) {
      return mapped.id;
    }

    // 本地主键与服务端 id 数值相同时须校验映射，避免 id=1 误绑到其他物品
    final byLocalId = await _db.getItemById(serverItemId);
    if (byLocalId != null) {
      final boundServer = byLocalId.serverItemId;
      if (boundServer == null) {
        await _db.ensureItemServerItemId(byLocalId.id, serverItemId);
        return byLocalId.id;
      }
      if (boundServer == serverItemId) {
        return byLocalId.id;
      }
      debugPrint(
        '[ItemSync] WARN: 本地 id=$serverItemId 已绑定 serverId=$boundServer，'
        '与目标 $serverItemId 冲突，改拉取新行',
      );
    }

    final remote = await _itemService.getItemDetail(itemId: serverItemId);
    if (remote.code != 200 || remote.data == null) {
      debugPrint(
        '[ItemSync] WARN: 服务端物品不存在 serverId=$serverItemId code=${remote.code}',
      );
      return null;
    }

    try {
      final useAutoId = byLocalId != null;
      final localId = await _insertServerItemFromRemote(
        remote.data!,
        forceAutoId: useAutoId,
      );
      debugPrint(
        '[ItemSync] INFO: 问管管拉取物品入库 serverId=$serverItemId localId=$localId',
      );
      return localId;
    } catch (e) {
      debugPrint(
        '[ItemSync] ERROR: 问管管拉取物品失败 serverId=$serverItemId err=$e',
      );
      return null;
    }
  }

  /// 写入服务端物品；forceAutoId 时不用服务端 id 作主键（避免本地 id 冲突）
  Future<int> _insertServerItemFromRemote(
    Map<String, dynamic> json, {
    bool forceAutoId = false,
  }) async {
    final companion = _serverItemToCompanion(json, forceAutoId: forceAutoId);
    return _db.insertItem(companion);
  }

  /// 从服务端同步物品到本地数据库
  ///
  /// - 本地已存在的物品（同 ID）：跳过（避免覆盖本地更完整的数据）
  /// - 本地不存在的物品：插入（覆盖缓存清理/新设备登录场景）
  /// - 用户已删除的物品（ItemDeletedRegistry）：不再恢复
  /// - 服务端已删、本地仍有的物品：清理本地副本
  ///
  /// 返回同步后本地物品总数
  Future<int> syncFromServer() async {
    try {
      final serverItems = await _itemService.getAllItemsFromServer();
      if (serverItems.isEmpty) {
        debugPrint('[ItemSync] INFO: 服务端无物品，跳过同步');
        return await _countLocalItems();
      }

      final serverIds = <int>{};
      int inserted = 0;
      int skipped = 0;
      int removedLocal = 0;
      int updatedImages = 0;

      for (final serverItem in serverItems) {
        final id = _parseId(serverItem['id']);
        if (id == null) continue;
        serverIds.add(id);

        // 用户已删除 — 不恢复，并清理本地残留
        if (await ItemDeletedRegistry.isDeleted(id)) {
          final existing = await _db.getItemById(id);
          if (existing != null) {
            await _db.deleteItem(existing.id);
            removedLocal++;
            debugPrint('[ItemSync] INFO: 清理已删物品残留 id=$id');
          }
          continue;
        }

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
          final srvLastUsedAt = serverItem['last_used_at'];

          final shouldUpdatePreview = preview != null &&
              preview.isNotEmpty &&
              _shouldUpdatePreviewImage(preview, existing.images);

          final needsUpdate = currentQty != null ||
              purchaseQty != null ||
              srvAvgDaily != null ||
              srvPredictedEmpty != null ||
              srvLastUsedAt != null ||
              serverItem['search_aliases'] != null ||
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
              lastUsedAt: srvLastUsedAt != null
                  ? Value(DateTime.tryParse(srvLastUsedAt.toString()))
                  : const Value.absent(),
              searchAliases: _aliasesValueFromJson(serverItem['search_aliases']),
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

      // 服务端已不存在、本地仍有的同步物品 — 删除本地副本
      final localAll = await _db.getAllItems();
      for (final local in localAll) {
        final sid = local.serverItemId;
        if (sid == null) continue;
        if (!serverIds.contains(sid)) {
          await _db.deleteItem(local.id);
          removedLocal++;
          debugPrint('[ItemSync] INFO: 移除服务端已删物品 local=${local.id} server=$sid');
        }
      }

      final total = await _countLocalItems();
      debugPrint(
        '[ItemSync] INFO: 同步完成 — 新增 $inserted 件, '
        '已存在 $skipped 件, 补图 $updatedImages 件, 清理 $removedLocal 件, 本地共 $total 件',
      );
      return total;
    } catch (e) {
      debugPrint('[ItemSync] ERROR: 同步失败 — $e');
      return await _countLocalItems();
    }
  }

  /// 将服务端物品 JSON 转为 Drift InsertCompanion
  ItemsCompanion _serverItemToCompanion(
    Map<String, dynamic> json, {
    bool forceAutoId = false,
  }) {
    final name = json['name']?.toString() ?? '未知物品';
    final serverId = _parseId(json['id']);

    return ItemsCompanion(
      id: forceAutoId || serverId == null ? const Value.absent() : Value(serverId),
      serverItemId: serverId != null ? Value(serverId) : const Value.absent(),
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
      lastUsedAt: json['last_used_at'] != null
          ? Value(DateTime.tryParse(json['last_used_at'].toString()))
          : const Value.absent(),
      searchAliases: _aliasesValueFromJson(json['search_aliases']),
      // 如果有预览图，以 JSON 数组格式存入本地
      images: json['preview_image'] != null
          ? Value(jsonEncode([json['preview_image']]))
          : const Value.absent(),
    );
  }

  /// 服务端 search_aliases(list|string) → Drift Value
  Value<String?> _aliasesValueFromJson(dynamic raw) {
    if (raw == null) return const Value.absent();
    if (raw is List) {
      final list = raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      if (list.isEmpty) return const Value.absent();
      return Value(jsonEncode(list));
    }
    final s = raw.toString().trim();
    if (s.isEmpty) return const Value.absent();
    return Value(s);
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
