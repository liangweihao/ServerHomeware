import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../events/item_event_bus.dart';
import '../services/item_id_resolver.dart';
import '../services/item_service.dart';
import 'database_provider.dart';
import '../../presentation/inventory/inventory_task_storage.dart';

/// 盘点单项状态
enum InventoryCheckStatus {
  pending,
  confirmed,
  adjusted,
  skipped,
}

/// 盘点修正明细（会话内）
@immutable
class InventoryAdjustmentRecord {
  const InventoryAdjustmentRecord({
    required this.itemName,
    required this.oldQty,
    required this.newQty,
    required this.unit,
  });

  final String itemName;
  final double oldQty;
  final double newQty;
  final String unit;
}

/// 盘点会话
@immutable
class InventorySession {
  const InventorySession({
    this.locationId,
    this.locationName,
    this.items = const [],
    this.statusByItemId = const {},
    this.adjustedQtyByItemId = const {},
    this.adjustmentRecords = const [],
    this.expiredAlertCount = 0,
    this.expiringAlertCount = 0,
    this.completed = false,
  });

  final int? locationId;
  final String? locationName;
  final List<Item> items;
  final Map<int, InventoryCheckStatus> statusByItemId;
  final Map<int, double> adjustedQtyByItemId;
  final List<InventoryAdjustmentRecord> adjustmentRecords;
  final int expiredAlertCount;
  final int expiringAlertCount;
  final bool completed;

  int get totalCount => items.length;
  int get doneCount => statusByItemId.values
      .where((s) => s != InventoryCheckStatus.pending)
      .length;
  int get confirmedCount => statusByItemId.values
      .where((s) => s == InventoryCheckStatus.confirmed)
      .length;
  int get adjustedCount => statusByItemId.values
      .where((s) => s == InventoryCheckStatus.adjusted)
      .length;
  int get skippedCount => statusByItemId.values
      .where((s) => s == InventoryCheckStatus.skipped)
      .length;

  double get progress =>
      totalCount == 0 ? 0 : doneCount / totalCount;

  InventorySession copyWith({
    int? locationId,
    String? locationName,
    List<Item>? items,
    Map<int, InventoryCheckStatus>? statusByItemId,
    Map<int, double>? adjustedQtyByItemId,
    List<InventoryAdjustmentRecord>? adjustmentRecords,
    int? expiredAlertCount,
    int? expiringAlertCount,
    bool? completed,
  }) {
    return InventorySession(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      items: items ?? this.items,
      statusByItemId: statusByItemId ?? this.statusByItemId,
      adjustedQtyByItemId: adjustedQtyByItemId ?? this.adjustedQtyByItemId,
      adjustmentRecords: adjustmentRecords ?? this.adjustmentRecords,
      expiredAlertCount: expiredAlertCount ?? this.expiredAlertCount,
      expiringAlertCount: expiringAlertCount ?? this.expiringAlertCount,
      completed: completed ?? this.completed,
    );
  }
}

/// 带物品数量的盘点空间选项
class InventoryLocationOption {
  const InventoryLocationOption({
    required this.location,
    required this.itemCount,
  });

  final Location location;
  final int itemCount;
}

/// 盘点任务状态管理
class InventoryTaskNotifier extends StateNotifier<InventorySession> {
  InventoryTaskNotifier(this._ref) : super(const InventorySession());

  final Ref _ref;

  /// 选择空间并加载待核对物品（含子空间）
  Future<void> startForLocation(int locationId, String locationName) async {
    debugPrint('[InventoryTask] INFO: 开始盘点 location=$locationName');
    final db = _ref.read(databaseProvider);
    final activeItems = await db.getItemsInLocationTree(locationId);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var expired = 0;
    var expiring = 0;
    for (final item in activeItems) {
      final expiry = item.expiryDate;
      if (expiry == null) continue;
      final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
      if (expiryDay.isBefore(today)) {
        expired++;
      } else {
        final days = expiryDay.difference(today).inDays;
        if (days <= 7) expiring++;
      }
    }

    state = InventorySession(
      locationId: locationId,
      locationName: locationName,
      items: activeItems,
      statusByItemId: {
        for (final item in activeItems) item.id: InventoryCheckStatus.pending,
      },
      expiredAlertCount: expired,
      expiringAlertCount: expiring,
    );
    debugPrint(
      '[InventoryTask] INFO: 加载 ${activeItems.length} 件，过期=$expired 临期=$expiring',
    );
  }

  /// 空空间直接完成盘点
  void completeEmptyLocation() {
    if (state.totalCount != 0) return;
    debugPrint('[InventoryTask] INFO: 空空间盘点完成');
    state = state.copyWith(completed: true);
    unawaited(_saveHistory());
  }

  void confirmItem(int itemId) {
    debugPrint('[InventoryTask] INFO: 确认 itemId=$itemId');
    final next = Map<int, InventoryCheckStatus>.from(state.statusByItemId);
    next[itemId] = InventoryCheckStatus.confirmed;
    state = state.copyWith(statusByItemId: next);
    _tryComplete();
  }

  void skipItem(int itemId) {
    debugPrint('[InventoryTask] INFO: 跳过 itemId=$itemId');
    final next = Map<int, InventoryCheckStatus>.from(state.statusByItemId);
    next[itemId] = InventoryCheckStatus.skipped;
    state = state.copyWith(statusByItemId: next);
    _tryComplete();
  }

  void adjustItem(int itemId, double newQty) {
    debugPrint('[InventoryTask] INFO: 修正 itemId=$itemId qty=$newQty');
    final item = state.items.firstWhere((i) => i.id == itemId);
    final nextStatus = Map<int, InventoryCheckStatus>.from(state.statusByItemId);
    final nextQty = Map<int, double>.from(state.adjustedQtyByItemId);
    nextStatus[itemId] = InventoryCheckStatus.adjusted;
    nextQty[itemId] = newQty;

    final records = List<InventoryAdjustmentRecord>.from(state.adjustmentRecords)
      ..removeWhere((r) => r.itemName == item.name)
      ..add(
        InventoryAdjustmentRecord(
          itemName: item.name,
          oldQty: item.currentQuantity,
          newQty: newQty,
          unit: item.unit,
        ),
      );

    state = state.copyWith(
      statusByItemId: nextStatus,
      adjustedQtyByItemId: nextQty,
      adjustmentRecords: records,
    );
    _persistAdjustedQuantity(itemId, newQty);
    _tryComplete();
  }

  /// 修正后写回本地并同步服务端
  Future<void> _persistAdjustedQuantity(int itemId, double newQty) async {
    try {
      final db = _ref.read(databaseProvider);
      final item = await db.getItemById(itemId);
      if (item == null) return;

      await db.updateItem(
        item.copyWith(
          currentQuantity: newQty,
          updatedAt: DateTime.now(),
        ),
      );

      final serverId = await ItemIdResolver(db).toServerId(itemId);
      if (serverId != null) {
        final resp = await ItemService().updateItem(
          itemId: serverId,
          body: {'current_quantity': newQty},
        );
        if (resp.isSuccess) {
          debugPrint('[InventoryTask] INFO: 服务端库存已同步 itemId=$serverId');
        } else {
          debugPrint('[InventoryTask] WARN: 服务端同步失败 ${resp.message}');
        }
      }

      _ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: itemId);
      debugPrint('[InventoryTask] INFO: 本地库存已更新 itemId=$itemId');
    } catch (e) {
      debugPrint('[InventoryTask] WARN: 库存更新失败 $e');
    }
  }

  void reset() {
    state = const InventorySession();
  }

  void _tryComplete() {
    if (state.totalCount > 0 && state.doneCount >= state.totalCount) {
      state = state.copyWith(completed: true);
      debugPrint('[InventoryTask] INFO: 盘点完成');
      unawaited(_saveHistory());
    }
  }

  Future<void> _saveHistory() async {
    await InventoryTaskStorage.append(
      InventoryHistoryEntry(
        completedAt: DateTime.now(),
        locationName: state.locationName ?? '',
        totalCount: state.totalCount,
        confirmedCount: state.confirmedCount,
        adjustedCount: state.adjustedCount,
        skippedCount: state.skippedCount,
        expiredAlertCount: state.expiredAlertCount,
        expiringAlertCount: state.expiringAlertCount,
        adjustments: state.adjustmentRecords
            .map(
              (r) => InventoryAdjustmentDetail(
                itemName: r.itemName,
                oldQty: r.oldQty,
                newQty: r.newQty,
                unit: r.unit,
              ),
            )
            .toList(),
      ),
    );
  }
}

final inventoryTaskProvider =
    StateNotifierProvider<InventoryTaskNotifier, InventorySession>((ref) {
  return InventoryTaskNotifier(ref);
});

/// 顶层位置 + 子空间物品数量（盘点选空间）
final inventoryLocationOptionsProvider =
    FutureProvider<List<InventoryLocationOption>>((ref) async {
  final db = ref.watch(databaseProvider);
  final locations = await db.getTopLevelLocations();
  final options = <InventoryLocationOption>[];
  for (final loc in locations) {
    final items = await db.getItemsInLocationTree(loc.id);
    options.add(InventoryLocationOption(location: loc, itemCount: items.length));
  }
  return options;
});
