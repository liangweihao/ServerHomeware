import 'package:flutter/foundation.dart' show debugPrint;
import 'package:drift/drift.dart' show Value;
import '../../data/database/app_database.dart';
import 'item_id_resolver.dart';
import 'item_service.dart';
import 'item_sync_service.dart';

/// 使用记录双向同步 — 本地写入 + 补推 + 服务端拉取
class UsageRecordSyncService {
  final AppDatabase _db;
  final ItemService _itemService;
  final ItemIdResolver _itemIdResolver;

  UsageRecordSyncService(
    this._db, {
    ItemService? itemService,
    ItemIdResolver? itemIdResolver,
  })  : _itemService = itemService ?? ItemService(),
        _itemIdResolver = itemIdResolver ?? ItemIdResolver(_db);

  /// 双向同步：先同步物品再拉取/补推 usage（保证 itemId 可解析）
  Future<({int pulled, int pushed})> syncBidirectional() async {
    await ItemSyncService(_db).syncFromServer();
    final pulled = await syncFromServer();
    final pushed = await pushPendingRecords();
    debugPrint(
      '[UsageRecordSync] INFO: 双向同步完成 pulled=$pulled pushed=$pushed',
    );
    return (pulled: pulled, pushed: pushed);
  }

  /// 写入本地并尝试立即推送服务端
  Future<int> recordAndSync({
    required int itemId,
    required int type,
    required double quantity,
    required double remainingQuantity,
    String? operatorName,
    String? notes,
  }) async {
    final localId = await _db.insertUsageRecord(
      UsageRecordsCompanion.insert(
        itemId: itemId,
        type: type,
        quantity: quantity,
        remainingQuantity: remainingQuantity,
        operatorName: operatorName != null && operatorName.isNotEmpty
            ? Value(operatorName)
            : const Value.absent(),
        notes: notes != null && notes.isNotEmpty
            ? Value(notes)
            : const Value.absent(),
      ),
    );
    await _pushSingleRecord(localId);
    return localId;
  }

  /// 补推所有未同步记录（离线期间产生）
  Future<int> pushPendingRecords() async {
    final pending = await _db.getUnsyncedUsageRecords();
    if (pending.isEmpty) return 0;

    var pushed = 0;
    for (final record in pending) {
      final ok = await _pushSingleRecord(record.id);
      if (ok) pushed++;
    }
    debugPrint('[UsageRecordSync] INFO: 补推 $pushed/${pending.length} 条');
    return pushed;
  }

  /// 从服务端拉取并合并到本地（按 serverRecordId 去重）
  Future<int> syncFromServer() async {
    try {
      final serverRecords = await _itemService.getAllUsageRecordsFromServer();
      if (serverRecords.isEmpty) {
        debugPrint('[UsageRecordSync] INFO: 服务端无使用记录');
        return 0;
      }

      final localRecords = await _db.getRecentUsageRecords(limit: 2000);
      final localServerIds = localRecords
          .where((r) => r.serverRecordId != null)
          .map((r) => r.serverRecordId!)
          .toSet();
      final localTimeKeys = localRecords
          .map((r) => '${r.itemId}_${r.type}_${r.createdAt.toIso8601String()}')
          .toSet();

      var inserted = 0;
      var skipped = 0;

      for (final serverRecord in serverRecords) {
        final serverId = _parseId(serverRecord['id']);
        if (serverId != null && localServerIds.contains(serverId)) {
          skipped++;
          continue;
        }

        final createdAt = DateTime.tryParse(
          serverRecord['created_at']?.toString() ?? '',
        );
        if (createdAt == null) continue;

        final serverItemIdRaw = _parseId(serverRecord['item_id']) ?? 0;
        final localItemId =
            await _itemIdResolver.toLocalId(serverItemIdRaw);
        if (localItemId == null) {
          debugPrint(
            '[UsageRecordSync] WARN: 跳过无本地映射 usage serverItemId=$serverItemIdRaw',
          );
          skipped++;
          continue;
        }

        final type = _parseInt(serverRecord['type']);
        final timeKey =
            '${localItemId}_${type}_${createdAt.toIso8601String()}';
        if (localTimeKeys.contains(timeKey)) {
          // 旧数据无 serverRecordId：尝试回填
          if (serverId != null) {
            final match = localRecords.where((r) =>
                r.serverRecordId == null &&
                r.itemId == localItemId &&
                r.type == type &&
                r.createdAt.toIso8601String() == createdAt.toIso8601String());
            if (match.isNotEmpty) {
              await _db.setUsageRecordServerId(match.first.id, serverId);
            }
          }
          skipped++;
          continue;
        }

        try {
          await _db.insertUsageRecord(
            UsageRecordsCompanion(
              itemId: Value(localItemId),
              type: Value(type),
              quantity: Value(_parseDouble(serverRecord['quantity'])),
              remainingQuantity:
                  Value(_parseDouble(serverRecord['remaining_quantity'])),
              operatorName: serverRecord['operator_name'] != null
                  ? Value(serverRecord['operator_name'].toString())
                  : const Value.absent(),
              notes: serverRecord['notes'] != null
                  ? Value(serverRecord['notes'].toString())
                  : const Value.absent(),
              serverRecordId:
                  serverId != null ? Value(serverId) : const Value.absent(),
              createdAt: Value(createdAt),
            ),
          );
          inserted++;
        } catch (e) {
          debugPrint('[UsageRecordSync] WARN: 插入失败 $e');
        }
      }

      debugPrint(
        '[UsageRecordSync] INFO: 拉取完成 — 新增 $inserted, 跳过 $skipped',
      );
      return inserted;
    } catch (e) {
      debugPrint('[UsageRecordSync] ERROR: 拉取失败 $e');
      return 0;
    }
  }

  /// 推送单条本地记录到服务端
  Future<bool> _pushSingleRecord(int localId) async {
    final record = await _db.getUsageRecordById(localId);
    if (record == null || record.serverRecordId != null) return false;

    try {
      final serverItemId =
          await _itemIdResolver.toServerId(record.itemId);
      if (serverItemId == null) {
        debugPrint(
          '[UsageRecordSync] WARN: 无法解析服务端 itemId local=${record.itemId}',
        );
        return false;
      }

      final result = await _itemService.createUsageRecord(
        itemId: serverItemId,
        type: record.type,
        quantity: record.quantity,
        remainingQuantity: record.remainingQuantity,
        operatorName: record.operatorName,
        notes: record.notes,
      );
      if (result.code != 200) {
        debugPrint(
          '[UsageRecordSync] WARN: 推送失败 localId=$localId code=${result.code}',
        );
        return false;
      }

      final serverId = _parseId(result.data?['id']);
      if (serverId != null) {
        await _db.setUsageRecordServerId(localId, serverId);
        debugPrint(
          '[UsageRecordSync] INFO: 已推送 localId=$localId serverId=$serverId',
        );
      }
      return true;
    } catch (e) {
      debugPrint('[UsageRecordSync] WARN: 推送异常 localId=$localId $e');
      return false;
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
