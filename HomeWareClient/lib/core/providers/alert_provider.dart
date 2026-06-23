import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../events/item_event_bus.dart';
import '../models/alert_tab.dart';
import '../models/alert_type.dart';
import '../models/notification_entry.dart';
import '../utils/alert_display_helper.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';
import 'family_provider.dart';

/// 当前家庭 ID（本地提醒已读状态隔离）
final currentFamilyIdProvider = Provider<int>((ref) {
  final family = ref.watch(currentFamilyProvider).valueOrNull;
  if (family == null) return 0;
  final id = family['id'];
  if (id is int) return id;
  if (id is String) return int.tryParse(id) ?? 0;
  return 0;
});

/// 未读提醒数量（首页 Badge + 提醒 Tab Badge 真源）
final unreadAlertCountProvider = FutureProvider<int>((ref) async {
  ref.watch(itemEventBusProvider);
  final familyId = ref.watch(currentFamilyIdProvider);
  final db = ref.watch(databaseProvider);
  return db.getUnreadAlertCount(familyId);
});

/// 未读通知列表（通知中心页，含位置路径）
final unreadNotificationsProvider = FutureProvider<List<NotificationEntry>>((ref) async {
  ref.watch(itemEventBusProvider);
  final familyId = ref.watch(currentFamilyIdProvider);
  final db = ref.watch(databaseProvider);
  final rows = await db.getUnreadNotifications(familyId, limit: 20);
  final locations = await db.getAllLocations();
  final pathById = {
    for (final loc in locations)
      loc.id: loc.fullPath.replaceAll('/', ' › '),
  };

  return rows
      .map(
        (row) => NotificationEntry(
          item: row.$1,
          alertTypeKey: row.$2,
          urgency: row.$3,
          locationPath: row.$1.locationId != null
              ? pathById[row.$1.locationId]
              : null,
        ),
      )
      .toList();
});

/// 提醒 Tab 列表
final alertListProvider =
    FutureProvider.family<List<(Item, AlertType)>, AlertTab>((ref, tab) async {
  ref.watch(itemEventBusProvider);
  final familyId = ref.watch(currentFamilyIdProvider);
  final db = ref.watch(databaseProvider);
  final typeFilter = _tabToTypeFilter(tab);
  final rows = await db.getAlertsForDisplay(
    familyId,
    typeFilter: typeFilter,
    excludeIgnored: true,
  );
  return rows
      .map((row) => (row.$1, alertTypeFromKey(row.$2)))
      .toList();
});

String? _tabToTypeFilter(AlertTab tab) {
  switch (tab) {
    case AlertTab.all:
      return 'all';
    case AlertTab.expiry:
      return 'expiry';
    case AlertTab.stock:
      return 'stock';
    case AlertTab.restock:
      return 'restock';
    case AlertTab.warranty:
      return 'warranty';
  }
}

/// 刷新提醒相关 Provider
void invalidateAlertProviders(WidgetRef ref) {
  ref.invalidate(unreadAlertCountProvider);
  ref.invalidate(unreadNotificationsProvider);
  ref.invalidate(alertListProvider);
}

void _logAlert(String message) {
  debugPrint('[AlertProvider] $message');
}

/// 标记全部已读并刷新
Future<void> markAllAlertsReadAction(WidgetRef ref) async {
  final familyId = ref.read(currentFamilyIdProvider);
  final db = ref.read(databaseProvider);
  await db.markAllAlertsRead(familyId);
  invalidateAlertProviders(ref);
  _logAlert('INFO: 全部已读 familyId=$familyId');
}

/// 忽略提醒并刷新
Future<void> ignoreAlertAction(
  WidgetRef ref,
  int itemId,
  AlertType type,
) async {
  final familyId = ref.read(currentFamilyIdProvider);
  final db = ref.read(databaseProvider);
  await db.ignoreAlert(itemId, alertTypeToKey(type), familyId);
  invalidateAlertProviders(ref);
  _logAlert('INFO: 忽略提醒 itemId=$itemId type=$type');
}
