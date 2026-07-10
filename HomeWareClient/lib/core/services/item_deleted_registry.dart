import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// 用户已删除的服务端物品 ID 登记 — 防止 sync 从服务端恢复
class ItemDeletedRegistry {
  ItemDeletedRegistry._();

  static const _key = 'deleted_server_item_ids_v1';

  /// 是否已登记为已删除
  static Future<bool> isDeleted(int serverItemId) async {
    final ids = await _load();
    return ids.contains(serverItemId);
  }

  /// 登记服务端物品 ID（用户主动删除后调用）
  static Future<void> markDeleted(int serverItemId) async {
    if (serverItemId <= 0) return;
    final ids = await _load();
    if (ids.add(serverItemId)) {
      await _save(ids);
      debugPrint('[ItemDeletedRegistry] INFO: 登记已删 serverId=$serverItemId');
    }
  }

  /// 服务端确认不存在时可从登记中移除（可选清理）
  static Future<void> unmark(int serverItemId) async {
    final ids = await _load();
    if (ids.remove(serverItemId)) {
      await _save(ids);
    }
  }

  static Future<Set<int>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => (e as num).toInt()).toSet();
    } catch (e) {
      debugPrint('[ItemDeletedRegistry] WARN: 解析失败，重置 $e');
      return {};
    }
  }

  static Future<void> _save(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = ids.toList()..sort();
    await prefs.setString(_key, jsonEncode(sorted));
  }
}
