import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import 'api_service.dart';

/// 入库草稿魔法增强 — 调用 `/assistant/enrich-item`
class ItemEnrichService {
  const ItemEnrichService();

  /// 根据已填字段生成备注 + 检索别名
  Future<({String notes, List<String> searchAliases})?> enrichDraft({
    required String name,
    String? brand,
    String? categoryName,
    String? specification,
    String? existingNotes,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      debugPrint('[ItemEnrich] WARN: 名称为空，跳过魔法备注');
      return null;
    }

    try {
      final body = <String, dynamic>{
        'name': trimmed,
        if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
        if (categoryName != null && categoryName.trim().isNotEmpty)
          'category_name': categoryName.trim(),
        if (specification != null && specification.trim().isNotEmpty)
          'specification': specification.trim(),
        if (existingNotes != null && existingNotes.trim().isNotEmpty)
          'existing_notes': existingNotes.trim(),
      };
      debugPrint('[ItemEnrich] INFO: 请求魔法备注 name=$trimmed');
      final resp = await ApiService.post('/assistant/enrich-item', body: body);
      if (resp['code'] != 200) {
        debugPrint(
          '[ItemEnrich] WARN: 失败 code=${resp['code']} msg=${resp['message']}',
        );
        return null;
      }
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      final notes = data['notes']?.toString() ?? '';
      final rawAliases = data['search_aliases'];
      final aliases = <String>[];
      if (rawAliases is List) {
        for (final a in rawAliases) {
          final s = a.toString().trim();
          if (s.isNotEmpty && !aliases.contains(s)) aliases.add(s);
        }
      }
      debugPrint(
        '[ItemEnrich] INFO: 成功 notes_len=${notes.length} aliases=$aliases',
      );
      return (notes: notes, searchAliases: aliases);
    } catch (e) {
      debugPrint('[ItemEnrich] ERROR: $e');
      return null;
    }
  }

  /// List → 本地/请求体存储字符串
  static String? encodeAliases(List<String>? aliases) {
    if (aliases == null || aliases.isEmpty) return null;
    return jsonEncode(aliases);
  }

  /// 存储字符串 → List
  static List<String> decodeAliases(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
