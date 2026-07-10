import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import '../config/space_skin_config.dart';
import '../services/llm_assistant_service.dart';
import 'assistant_item_resolver.dart';
import 'assistant_local_inventory.dart';
import 'assistant_models.dart';

/// 对话助手执行器 — 直连 LLM，多轮上下文由服务端 DB 维护
class AssistantExecutor {
  AssistantExecutor({
    required AppDatabase db,
    SpaceSkinConfig? skin,
    LlmAssistantService? llm,
  })  : _db = db,
        _skin = skin ?? SpaceSkinConfig.home,
        _llm = llm ?? const LlmAssistantService();

  final AppDatabase _db;
  final SpaceSkinConfig _skin;
  final LlmAssistantService _llm;

  /// 处理用户一句话 — 统一走 LLM（附带本地库存快照供查询）
  Future<AssistantReply> handle(String userMessage) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) {
      debugPrint('[AssistantExecutor] WARN: 空消息，返回帮助文案');
      return AssistantReply(
        text: _skin.helpReply(),
        suggestions: _skin.assistantSuggestions,
      );
    }

    final localItems = await AssistantLocalInventory.buildSnapshot(_db);
    debugPrint(
      '[AssistantExecutor] INFO: 直连 LLM local_items=${localItems.length}',
    );

    final reply = await _llm.chat(message: trimmed, localItems: localItems);
    final resolvedItems = await AssistantItemResolver.resolve(_db, reply.items);

    return AssistantReply(
      text: reply.text,
      items: resolvedItems,
      suggestions: reply.suggestions.isNotEmpty
          ? reply.suggestions
          : _skin.assistantSuggestions,
      actionLabel: reply.actionLabel,
      actionRoute: reply.actionRoute,
    );
  }
}
