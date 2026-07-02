/// 对话助手 — 意图类型（Phase 1 仅查询）
enum AssistantIntentType {
  /// 某空间下有什么物品
  querySpaceItems,

  /// 某物品在哪 / 还有没有
  queryItemLocation,

  /// 临期 / 过期
  queryExpiring,

  /// 库存不足
  queryLowStock,

  /// 待处理汇总
  queryPending,

  /// 无法理解 — 返回帮助
  unknown,
}

/// 规则解析结果
class AssistantParsedQuery {
  const AssistantParsedQuery({
    required this.intent,
    this.spaceName,
    this.itemName,
  });

  final AssistantIntentType intent;
  final String? spaceName;
  final String? itemName;
}

/// 助手回复中的物品摘要
class AssistantItemSummary {
  const AssistantItemSummary({
    required this.itemId,
    required this.name,
    required this.subtitle,
  });

  final int itemId;
  final String name;

  /// 位置 · 数量等副信息
  final String subtitle;
}

/// 执行器返回
class AssistantReply {
  const AssistantReply({
    required this.text,
    this.items = const [],
    this.suggestions = const [],
  });

  final String text;
  final List<AssistantItemSummary> items;

  /// 下一轮建议问题
  final List<String> suggestions;
}

/// 会话气泡
class AssistantChatMessage {
  const AssistantChatMessage({
    required this.isUser,
    required this.text,
    this.items = const [],
  });

  final bool isUser;
  final String text;
  final List<AssistantItemSummary> items;
}
