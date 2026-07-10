import 'package:flutter/foundation.dart' show debugPrint;

import '../services/api_service.dart';
import '../services/llm_assistant_service.dart';
import 'assistant_models.dart';

/// 问管管对话历史 — 服务端持久化（按账号 + 家庭）
class AssistantChatStorage {
  AssistantChatStorage._();

  static const maxLoad = 50;

  /// 从服务端加载最近对话
  static Future<List<AssistantChatMessage>> load() async {
    try {
      final resp = await ApiService.get('/assistant/history?limit=$maxLoad');
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      final raw = data['messages'] as List<dynamic>? ?? [];
      final messages = raw.map(_parseHistoryRow).toList();
      debugPrint('[AssistantChatStorage] INFO: 服务端加载历史 ${messages.length} 条');
      return messages;
    } catch (e) {
      debugPrint('[AssistantChatStorage] WARN: 加载历史失败 $e');
      return [];
    }
  }

  /// 服务端在 /chat 时自动保存，客户端无需逐条写入
  static Future<void> save(AssistantChatMessage message) async {
    debugPrint(
      '[AssistantChatStorage] INFO: 跳过本地保存（服务端已持久化） isUser=${message.isUser}',
    );
  }

  /// 清空服务端对话历史
  static Future<void> clear() async {
    try {
      final resp = await ApiService.delete('/assistant/history');
      final deleted = resp['data']?['deleted'] ?? 0;
      debugPrint('[AssistantChatStorage] INFO: 服务端清空 deleted=$deleted');
    } catch (e) {
      debugPrint('[AssistantChatStorage] ERROR: 清空历史失败 $e');
      rethrow;
    }
  }

  /// 从已加载气泡恢复 LLM 多轮上下文（仅内存展示用，实际上下文由服务端 DB 维护）
  static List<LlmChatMessage> toLlmHistory(List<AssistantChatMessage> messages) {
    return messages
        .map(
          (m) => LlmChatMessage(
            role: m.isUser ? 'user' : 'assistant',
            content: m.text,
          ),
        )
        .toList();
  }

  static AssistantChatMessage _parseHistoryRow(dynamic row) {
    final map = row as Map<String, dynamic>;
    final role = map['role'] as String? ?? 'assistant';
    final content = map['content'] as String? ?? '';
    final meta = map['meta'] as Map<String, dynamic>?;
    return AssistantChatMessage(
      isUser: role == 'user',
      text: content,
      items: _parseItems(meta),
      actionLabel: meta?['actionLabel'] as String?,
      actionRoute: meta?['actionRoute'] as String?,
    );
  }

  static List<AssistantItemSummary> _parseItems(Map<String, dynamic>? meta) {
    if (meta == null) return const [];
    final raw = meta['items'] as List<dynamic>? ?? [];
    return raw
        .map((e) {
          final m = e as Map<String, dynamic>;
          return AssistantItemSummary(
            itemId: m['local_id'] as int? ??
                m['localId'] as int? ??
                0,
            serverItemId: m['item_id'] as int? ?? m['serverItemId'] as int?,
            name: m['name'] as String? ?? '',
            subtitle: m['subtitle'] as String? ?? '',
          );
        })
        .toList();
  }
}
