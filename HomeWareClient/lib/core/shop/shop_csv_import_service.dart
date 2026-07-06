import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import '../services/item_id_resolver.dart';
import '../services/item_service.dart';
import '../services/usage_record_sync_service.dart';
import 'shop_csv_import_models.dart';
import 'shop_import_lookup.dart';

/// B+ CSV 批量进货 — 优先 bulk API，失败行可逐条回退
class ShopCsvImportService {
  ShopCsvImportService({
    required AppDatabase db,
    ItemService? itemService,
  })  : _db = db,
        _itemService = itemService ?? ItemService();

  final AppDatabase _db;
  final ItemService _itemService;

  static const _bulkChunkSize = 100;

  /// 执行导入；[onProgress] 报告已完成条数
  Future<ShopCsvImportResult> importRows({
    required List<ShopCsvImportRow> rows,
    required ShopImportLookup lookup,
    void Function(int done, int total)? onProgress,
  }) async {
    final valid = rows.where((r) => r.isValid).toList();
    final skipped = rows.length - valid.length;
    final failures = <ShopCsvImportFailure>[];
    var success = 0;
    var done = 0;

    for (var start = 0; start < valid.length; start += _bulkChunkSize) {
      final chunk = valid.sublist(
        start,
        (start + _bulkChunkSize).clamp(0, valid.length),
      );
      final bodies = chunk.map((r) => _buildApiBody(row: r, lookup: lookup)).toList();

      final bulkResult = await _itemService.bulkCreateItems(items: bodies);
      if (bulkResult.code == 200 && bulkResult.data != null) {
        final data = bulkResult.data!;
        final items = (data['items'] as List?) ?? const [];
        final bulkFailures = (data['failures'] as List?) ?? const [];

        for (final entry in items) {
          if (entry is! Map) continue;
          final map = Map<String, dynamic>.from(entry);
          final itemJson = map['item'];
          if (itemJson is! Map) continue;
          final itemMap = Map<String, dynamic>.from(itemJson);
          final index = (map['index'] as num?)?.toInt() ?? -1;
          final row = index >= 0 && index < chunk.length ? chunk[index] : null;
          if (row == null) continue;

          final serverIdRaw = itemMap['id'];
          final serverId = serverIdRaw is int
              ? serverIdRaw
              : int.tryParse(serverIdRaw?.toString() ?? '');
          if (serverId == null) continue;

          await _persistLocal(
            row: row,
            serverId: serverId,
            body: _buildApiBody(row: row, lookup: lookup),
          );
          success++;
        }

        for (final f in bulkFailures) {
          if (f is! Map) continue;
          final index = (f['index'] as num?)?.toInt() ?? -1;
          final row = index >= 0 && index < chunk.length ? chunk[index] : null;
          failures.add(ShopCsvImportFailure(
            lineNumber: row?.lineNumber ?? (start + index + 2),
            name: f['name']?.toString() ?? row?.name ?? '',
            message: f['message']?.toString() ?? '创建失败',
          ));
        }

        done += chunk.length;
        onProgress?.call(done, valid.length);
        continue;
      }

      debugPrint(
        '[ShopCsvImportService] WARN: bulk API 不可用，回退逐条导入 '
        'code=${bulkResult.code}',
      );
      for (final row in chunk) {
        try {
          final ok = await _importOne(row: row, lookup: lookup);
          if (ok) {
            success++;
          } else {
            failures.add(ShopCsvImportFailure(
              lineNumber: row.lineNumber,
              name: row.name,
              message: '服务端创建失败',
            ));
          }
        } catch (e) {
          debugPrint('[ShopCsvImportService] ERROR: 行${row.lineNumber} $e');
          failures.add(ShopCsvImportFailure(
            lineNumber: row.lineNumber,
            name: row.name,
            message: '$e',
          ));
        }
        done++;
        onProgress?.call(done, valid.length);
      }
    }

    debugPrint(
      '[ShopCsvImportService] INFO: 导入完成 success=$success '
      'failed=${failures.length} skipped=$skipped',
    );

    return ShopCsvImportResult(
      total: rows.length,
      success: success,
      skipped: skipped,
      failures: failures,
    );
  }

  Map<String, dynamic> _buildApiBody({
    required ShopCsvImportRow row,
    required ShopImportLookup lookup,
  }) {
    final categoryId = lookup.resolveCategoryId(row.categoryName);
    final locationId = lookup.resolveLocationId(row.locationName);
    final purchaseQty = row.quantity.round();
    final body = <String, dynamic>{
      'name': row.name.trim(),
      'category_id': categoryId,
      'purchase_quantity': purchaseQty,
      'current_quantity': row.quantity,
      'unit': row.unit,
      'package_quantity': 1,
      'safety_stock': 1,
      'expiry_alert_days': 3,
      'stock_alert': true,
    };
    if (locationId != null) {
      body['location_id'] = locationId;
    }
    if (row.purchasePrice != null) {
      body['purchase_price'] = row.purchasePrice;
    }
    if (row.salePrice != null) {
      body['sale_price'] = row.salePrice;
    }
    if (row.supplier != null && row.supplier!.isNotEmpty) {
      body['supplier'] = row.supplier;
    }
    if (row.brand != null && row.brand!.isNotEmpty) {
      body['brand'] = row.brand;
    }
    if (row.barcode != null && row.barcode!.isNotEmpty) {
      body['barcode'] = row.barcode;
    }
    return body;
  }

  Future<bool> _importOne({
    required ShopCsvImportRow row,
    required ShopImportLookup lookup,
  }) async {
    final body = _buildApiBody(row: row, lookup: lookup);
    final result = await _itemService.createItem(body: body);
    if (result.code != 200 || result.data == null) {
      debugPrint(
        '[ShopCsvImportService] WARN: 行${row.lineNumber} API 失败 ${result.message}',
      );
      return false;
    }

    final serverIdRaw = result.data!['id'];
    final serverId = serverIdRaw is int
        ? serverIdRaw
        : int.tryParse(serverIdRaw?.toString() ?? '');
    if (serverId == null) return false;

    await _persistLocal(row: row, serverId: serverId, body: body);
    return true;
  }

  Future<void> _persistLocal({
    required ShopCsvImportRow row,
    required int serverId,
    required Map<String, dynamic> body,
  }) async {
    final existing = await _db.getItemById(serverId);
    if (existing != null) {
      await _db.updateItem(
        existing.copyWith(
          name: row.name.trim(),
          categoryId: body['category_id'] as int,
          locationId: body['location_id'] != null
              ? Value(body['location_id'] as int)
              : const Value.absent(),
          purchasePrice: row.purchasePrice != null
              ? Value(row.purchasePrice)
              : const Value.absent(),
          salePrice:
              row.salePrice != null ? Value(row.salePrice) : const Value.absent(),
          supplier: row.supplier != null
              ? Value(row.supplier)
              : const Value.absent(),
          purchaseQuantity: purchaseQtyFromBody(body),
          currentQuantity: (body['current_quantity'] as num).toDouble(),
          unit: body['unit'] as String,
          brand: row.brand != null ? Value(row.brand) : const Value.absent(),
          barcode: row.barcode != null ? Value(row.barcode) : const Value.absent(),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      await _db.insertItem(
        ItemsCompanion(
          id: Value(serverId),
          serverItemId: Value(serverId),
          name: Value(row.name.trim()),
          categoryId: Value(body['category_id'] as int),
          locationId: body['location_id'] != null
              ? Value(body['location_id'] as int)
              : const Value.absent(),
          purchasePrice: row.purchasePrice != null
              ? Value(row.purchasePrice)
              : const Value.absent(),
          salePrice:
              row.salePrice != null ? Value(row.salePrice) : const Value.absent(),
          supplier: row.supplier != null
              ? Value(row.supplier)
              : const Value.absent(),
          purchaseQuantity: Value(purchaseQtyFromBody(body)),
          currentQuantity: Value((body['current_quantity'] as num).toDouble()),
          unit: Value(body['unit'] as String),
          packageQuantity: const Value(1),
          safetyStock: const Value(1),
          expiryAlertDays: const Value(3),
          stockAlert: const Value(true),
          status: const Value(0),
          brand: row.brand != null ? Value(row.brand) : const Value.absent(),
          barcode: row.barcode != null ? Value(row.barcode) : const Value.absent(),
        ),
      );
    }

    await ItemIdResolver(_db).bind(
      localItemId: serverId,
      serverItemId: serverId,
    );

    final usages = await _db.getUsageRecordsByItem(serverId, limit: 1);
    if (usages.isEmpty) {
      await UsageRecordSyncService(_db).recordAndSync(
        itemId: serverId,
        type: 0,
        quantity: row.quantity,
        remainingQuantity: row.quantity,
        notes: 'CSV批量进货',
      );
    }
  }

  static int purchaseQtyFromBody(Map<String, dynamic> body) {
    return (body['purchase_quantity'] as num?)?.toInt() ?? 1;
  }
}
