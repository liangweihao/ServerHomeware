import 'add_item_nl_parser.dart';

/// 对话助手 — 意图类型（Phase 1 查询 + M5 入库预填）
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

  /// M5 — 规则 NL 添加入库预填
  addItem,

  /// 无法理解 — 返回帮助
  unknown,
}

/// 规则解析结果
class AssistantParsedQuery {
  const AssistantParsedQuery({
    required this.intent,
    this.spaceName,
    this.itemName,
    this.addItemDraft,
  });

  final AssistantIntentType intent;
  final String? spaceName;
  final String? itemName;
  final AddItemNlResult? addItemDraft;
}

/// 助手回复中的物品摘要
class AssistantItemSummary {
  const AssistantItemSummary({
    required this.itemId,
    required this.name,
    required this.subtitle,
    this.serverItemId,
  });

  /// 本地 Drift 主键 — 跳转详情用
  final int itemId;
  final String name;

  /// 位置 · 数量等副信息
  final String subtitle;

  /// 服务端 items.id — 本地无记录时用于拉取同步
  final int? serverItemId;
}

/// 执行器返回
class AssistantReply {
  const AssistantReply({
    required this.text,
    this.items = const [],
    this.suggestions = const [],
    this.actionLabel,
    this.actionRoute,
  });

  final String text;
  final List<AssistantItemSummary> items;

  /// 下一轮建议问题
  final List<String> suggestions;

  /// M5 — 引导用户进入向导的按钮文案
  final String? actionLabel;

  /// M5 — 跳转路由（如 `/items/add?nlPrefill=1`）
  final String? actionRoute;
}

/// 会话气泡
class AssistantChatMessage {
  const AssistantChatMessage({
    required this.isUser,
    required this.text,
    this.items = const [],
    this.actionLabel,
    this.actionRoute,
  });

  final bool isUser;
  final String text;
  final List<AssistantItemSummary> items;
  final String? actionLabel;
  final String? actionRoute;
}
