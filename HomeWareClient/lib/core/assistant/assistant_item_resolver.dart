import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import '../services/item_deleted_registry.dart';
import '../services/item_service.dart';
import '../services/item_sync_service.dart';
import 'assistant_models.dart';

/// 问管管 — 将 API 返回的物品卡片解析为可跳转的本地 Drift id
class AssistantItemResolver {
  AssistantItemResolver._();

  /// 从 /assistant/chat 响应中的 items 字段解析
  static List<AssistantItemSummary> parseFromApi(List<dynamic> raw) {
    return raw
        .map((e) {
          final m = e as Map<String, dynamic>;
          final localId = m['local_id'] as int? ?? m['localId'] as int? ?? 0;
          final serverId = m['item_id'] as int? ?? 0;
          final legacy = m['itemId'] as int? ?? 0;
          final resolvedServer = serverId > 0 ? serverId : legacy;
          return AssistantItemSummary(
            itemId: localId,
            serverItemId: resolvedServer > 0 ? resolvedServer : null,
            name: m['name'] as String? ?? '',
            subtitle: m['subtitle'] as String? ?? '',
          );
        })
        .where((i) => i.name.isNotEmpty)
        .toList();
  }

  /// 补全导航 id；无法本地解析时仍保留卡片（仅云端 / 待恢复）
  static Future<List<AssistantItemSummary>> resolve(
    AppDatabase db,
    List<AssistantItemSummary> items,
  ) async {
    if (items.isEmpty) return items;

    await db.ensureInitialized();
    final sync = ItemSyncService(db);
    final resolved = <AssistantItemSummary>[];

    for (final item in items) {
      final navId = await resolveNavId(db, sync, item);
      resolved.add(
        AssistantItemSummary(
          itemId: navId ?? 0,
          name: item.name,
          subtitle: item.subtitle,
          serverItemId: item.serverItemId,
        ),
      );
      if (navId != null) {
        debugPrint(
          '[AssistantItemResolver] INFO: 物品可跳转 name=${item.name} '
          'localId=$navId serverId=${item.serverItemId}',
        );
      } else if (item.serverItemId != null) {
        debugPrint(
          '[AssistantItemResolver] INFO: 物品仅云端可见 name=${item.name} '
          'serverId=${item.serverItemId}（点击可尝试恢复）',
        );
      } else {
        debugPrint(
          '[AssistantItemResolver] WARN: 无法解析物品 name=${item.name}',
        );
      }
    }
    return resolved;
  }

  /// 被动解析 — 不自动恢复已删除物品
  static Future<int?> resolveNavId(
    AppDatabase db,
    ItemSyncService sync,
    AssistantItemSummary item,
  ) async {
    await db.ensureInitialized();

    if (item.serverItemId != null &&
        await ItemDeletedRegistry.isDeleted(item.serverItemId!)) {
      return null;
    }

    return _resolveNavIdInternal(db, sync, item);
  }

  /// 用户点击卡片 — 若服务端仍有该物品，允许解除删除登记并恢复本地
  static Future<int?> resolveNavIdForTap(
    AppDatabase db,
    ItemSyncService sync,
    AssistantItemSummary item,
  ) async {
    await db.ensureInitialized();
    final serverId = item.serverItemId;

    if (serverId != null &&
        serverId > 0 &&
        await ItemDeletedRegistry.isDeleted(serverId)) {
      final remote = await ItemService().getItemDetail(itemId: serverId);
      if (remote.code == 200 && remote.data != null) {
        await ItemDeletedRegistry.unmark(serverId);
        debugPrint(
          '[AssistantItemResolver] INFO: 问管管点击恢复 serverId=$serverId',
        );
        final localId = await sync.ensureLocalByServerId(serverId);
        if (localId != null && await _verifyLocalRow(db, localId, item.name)) {
          return localId;
        }
      }
      debugPrint(
        '[AssistantItemResolver] WARN: 已删除且服务端不可用 serverId=$serverId',
      );
      return null;
    }

    final navId = await _resolveNavIdInternal(db, sync, item);
    if (navId != null) return navId;

    if (serverId != null && serverId > 0) {
      final pulled = await sync.ensureLocalByServerId(serverId);
      if (pulled != null && await _verifyLocalRow(db, pulled, item.name)) {
        return pulled;
      }
    }
    return null;
  }

  static Future<int?> _resolveNavIdInternal(
    AppDatabase db,
    ItemSyncService sync,
    AssistantItemSummary item,
  ) async {
    final allItems = await db.getAllItems();
    final byNameExact = {for (final i in allItems) _normalizeName(i.name): i};

    final serverId = item.serverItemId;
    if (serverId != null && serverId > 0) {
      final mapped = await db.getItemByServerItemId(serverId);
      if (mapped != null && _nameMatches(mapped.name, item.name)) {
        return mapped.id;
      }
      final pulled = await sync.ensureLocalByServerId(serverId);
      if (pulled != null && await _verifyLocalRow(db, pulled, item.name)) {
        return pulled;
      }
    }

    if (item.itemId > 0 && await _verifyLocalRow(db, item.itemId, item.name)) {
      return item.itemId;
    }

    final exact = byNameExact[_normalizeName(item.name)];
    if (exact != null) return exact.id;

    final fuzzy = _fuzzyMatchByName(allItems, item.name);
    if (fuzzy != null) return fuzzy.id;

    return null;
  }

  static Future<bool> _verifyLocalRow(
    AppDatabase db,
    int localId,
    String expectedName,
  ) async {
    final row = await db.getItemById(localId);
    if (row == null) return false;
    return _nameMatches(row.name, expectedName);
  }

  static String _normalizeName(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true), '');
    s = s.replaceAll(RegExp(r'（[^）]*）'), '');
    s = s.replaceAll(RegExp(r'\([^)]*\)'), '');
    return s.trim().toLowerCase();
  }

  static bool _nameMatches(String a, String b) {
    final na = _normalizeName(a);
    final nb = _normalizeName(b);
    if (na.isEmpty || nb.isEmpty) return false;
    return na == nb || na.contains(nb) || nb.contains(na);
  }

  static Item? _fuzzyMatchByName(List<Item> allItems, String name) {
    final key = _normalizeName(name);
    if (key.isEmpty) return null;

    Item? containsHit;
    for (final i in allItems) {
      final n = _normalizeName(i.name);
      if (n == key) return i;
      if (n.contains(key) || key.contains(n)) {
        containsHit ??= i;
      }
    }
    return containsHit;
  }
}
