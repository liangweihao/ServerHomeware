import 'package:flutter/foundation.dart' show debugPrint;
import 'package:drift/drift.dart' show Value;
import '../../data/database/app_database.dart';
import 'item_service.dart';

/// 使用记录服务端 → 本地数据库同步服务
class UsageRecordSyncService {
  final AppDatabase _db;
  final ItemService _itemService;

  UsageRecordSyncService(this._db) : _itemService = ItemService();

  /// 从服务端同步使用记录到本地
  ///
  /// - 本地不存在的记录才插入（通过服务端 id 判断）
  /// - 用于缓存清理后恢复使用记录
  Future<int> syncFromServer() async {
    try {
      final serverRecords = await _itemService.getAllUsageRecordsFromServer();
      if (serverRecords.isEmpty) {
        debugPrint('[UsageRecordSync] INFO: 服务端无使用记录，跳过同步');
        return 0;
      }

      int inserted = 0;
      int skipped = 0;

      // 获取本地已有的记录 ID 集合（通过匹配时间+物品避免重复）
      final localRecords = await _db.getRecentUsageRecords(limit: 1000);
      final localKeys = localRecords
          .map((r) => '${r.itemId}_${r.createdAt.toIso8601String()}')
          .toSet();

      for (final serverRecord in serverRecords) {
        // 用 item_id + created_at 作为唯一键去重
        final createdAt = DateTime.tryParse(
          serverRecord['created_at']?.toString() ?? '',
        );
        if (createdAt == null) continue;

        final key = '${_parseId(serverRecord['item_id'])}_${createdAt.toIso8601String()}';
        if (localKeys.contains(key)) {
          skipped++;
          continue;
        }

        try {
          await _db.insertUsageRecord(
            UsageRecordsCompanion(
              itemId: Value(_parseId(serverRecord['item_id']) ?? 0),
              type: Value(_parseInt(serverRecord['type'])),
              quantity: Value(_parseDouble(serverRecord['quantity'])),
              remainingQuantity: Value(_parseDouble(serverRecord['remaining_quantity'])),
              operatorName: serverRecord['operator_name'] != null
                  ? Value(serverRecord['operator_name'].toString())
                  : const Value.absent(),
              notes: serverRecord['notes'] != null
                  ? Value(serverRecord['notes'].toString())
                  : const Value.absent(),
              createdAt: Value(createdAt),
            ),
          );
          inserted++;
        } catch (e) {
          debugPrint('[UsageRecordSync] WARN: 插入记录失败: $e');
        }
      }

      debugPrint(
        '[UsageRecordSync] INFO: 同步完成 — 新增 $inserted 条, '
        '已存在 $skipped 条',
      );
      return inserted;
    } catch (e) {
      debugPrint('[UsageRecordSync] ERROR: 同步失败 — $e');
      return 0;
    }
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
}
