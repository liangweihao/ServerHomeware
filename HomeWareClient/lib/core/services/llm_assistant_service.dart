import 'package:flutter/foundation.dart' show debugPrint;

import 'api_service.dart';
import '../assistant/assistant_item_resolver.dart';
import '../assistant/assistant_models.dart';

/// LLM 对话消息（用于传递历史记录到服务端）
class LlmChatMessage {
  const LlmChatMessage({required this.role, required this.content});

  /// 'user' 或 'assistant'
  final String role;
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// LLM 助手服务 — 调用服务端 /assistant/chat 接口
class LlmAssistantService {
  const LlmAssistantService();

  /// 发送一条消息（多轮上下文由服务端 DB 维护；localItems 为本地库存快照）
  Future<AssistantReply> chat({
    required String message,
    List<Map<String, dynamic>> localItems = const [],
  }) async {
    debugPrint('[LlmAssistantService] INFO: 发送消息 preview=${message.substring(0, message.length.clamp(0, 30))}');

    try {
      final body = <String, dynamic>{
        'message': message,
        if (localItems.isNotEmpty) 'local_items': localItems,
      };

      final resp = await ApiService.post('/assistant/chat', body: body);
      final data = resp['data'] as Map<String, dynamic>? ?? {};

      final text = data['text'] as String? ?? '助手暂时无法回复，请稍后再试。';

      debugPrint('[LlmAssistantService] INFO: 收到回复 text_len=${text.length}');
      debugPrint('[LlmAssistantService] INFO: 回复内容 >>> $text');

      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = AssistantItemResolver.parseFromApi(rawItems);
      if (items.isNotEmpty) {
        debugPrint(
          '[LlmAssistantService] INFO: 可点击物品 items=${items.map((e) => e.name).toList()}',
        );
      }

      return AssistantReply(
        text: text,
        items: items,
        suggestions: const [],
      );
    } catch (e) {
      debugPrint('[LlmAssistantService] ERROR: 请求失败 $e');
      return const AssistantReply(
        text: 'AI 助手暂时无法响应，请检查网络后重试。',
        suggestions: [],
      );
    }
  }
}
