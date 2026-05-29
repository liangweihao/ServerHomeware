import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'item_events.dart';

/// 物品变更事件总线
///
/// 使用递增版本号（[state]）确保每次变更都能触发监听者更新。
/// 监听者通过 [lastEvent] 获取最新的变更详情。
///
/// 用法：
/// - 生产者（物品创建/更新/删除处）调用 [notifyCreated]/[notifyUpdated]/[notifyDeleted]
/// - 消费者（首页、列表页等）通过 `ref.listen(itemEventBusProvider, ...)` 监听并刷新 UI
class ItemEventBus extends StateNotifier<int> {
  ItemEventBus() : super(0);

  /// 最近一次变更事件
  ItemChangeEvent? _lastEvent;

  /// 获取最近一次变更事件
  ItemChangeEvent? get lastEvent => _lastEvent;

  /// 通知物品已创建
  void notifyCreated({int? itemId}) {
    debugPrint('[ItemEventBus] 物品创建通知${itemId != null ? " itemId=$itemId" : ""}');
    _lastEvent = ItemChangeEvent(type: ItemChangeType.created, itemId: itemId);
    state = state + 1;
  }

  /// 通知物品已更新
  void notifyUpdated({int? itemId}) {
    debugPrint('[ItemEventBus] 物品更新通知${itemId != null ? " itemId=$itemId" : ""}');
    _lastEvent = ItemChangeEvent(type: ItemChangeType.updated, itemId: itemId);
    state = state + 1;
  }

  /// 通知物品已删除
  void notifyDeleted({int? itemId}) {
    debugPrint('[ItemEventBus] 物品删除通知${itemId != null ? " itemId=$itemId" : ""}');
    _lastEvent = ItemChangeEvent(type: ItemChangeType.deleted, itemId: itemId);
    state = state + 1;
  }
}

/// 全局物品变更事件总线 Provider
final itemEventBusProvider = StateNotifierProvider<ItemEventBus, int>((ref) {
  return ItemEventBus();
});
