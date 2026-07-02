import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// 添加入库草稿 — 本地 SharedPreferences 持久化
class ItemAddDraftStorage {
  ItemAddDraftStorage._();

  static const _key = 'item_add_form_draft_v1';

  /// 是否存在草稿
  static Future<bool> hasDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    return raw != null && raw.isNotEmpty;
  }

  /// 读取草稿 JSON
  static Future<Map<String, dynamic>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      debugPrint('[ItemAddDraft] INFO: 读取草稿 step=${map['wizardStep']}');
      return map;
    } catch (e) {
      debugPrint('[ItemAddDraft] WARN: 读取草稿失败 $e');
      return null;
    }
  }

  /// 保存草稿
  static Future<void> save(Map<String, dynamic> draft) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      draft['savedAt'] = DateTime.now().toIso8601String();
      await prefs.setString(_key, jsonEncode(draft));
      debugPrint('[ItemAddDraft] INFO: 草稿已保存');
    } catch (e) {
      debugPrint('[ItemAddDraft] ERROR: 保存草稿失败 $e');
    }
  }

  /// 清除草稿（入库成功后）
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    debugPrint('[ItemAddDraft] INFO: 草稿已清除');
  }
}
