import 'assistant_models.dart';

/// 端侧规则解析 — 不依赖大模型（Phase 1）
class AssistantParser {
  static const _expiringKeywords = ['临期', '过期', '快过期', '到期', '还能放'];
  static const _lowStockKeywords = ['库存不足', '快没了', '不够', '低库存', '快用完'];
  static const _pendingKeywords = ['要处理', '待处理', '怎么办', '需要处理'];

  /// 解析用户输入
  static AssistantParsedQuery parse(String raw) {
    final msg = raw.trim();
    if (msg.isEmpty) {
      return const AssistantParsedQuery(intent: AssistantIntentType.unknown);
    }

    if (_containsAny(msg, _pendingKeywords)) {
      return const AssistantParsedQuery(intent: AssistantIntentType.queryPending);
    }
    if (_containsAny(msg, _expiringKeywords)) {
      return const AssistantParsedQuery(intent: AssistantIntentType.queryExpiring);
    }
    if (_containsAny(msg, _lowStockKeywords)) {
      return const AssistantParsedQuery(intent: AssistantIntentType.queryLowStock);
    }

    final space = _extractSpaceName(msg);
    if (space != null) {
      return AssistantParsedQuery(
        intent: AssistantIntentType.querySpaceItems,
        spaceName: space,
      );
    }

    final item = _extractItemName(msg);
    if (item != null) {
      return AssistantParsedQuery(
        intent: AssistantIntentType.queryItemLocation,
        itemName: item,
      );
    }

    // 短词默认当作物品名查询
    if (msg.length <= 12 && !_looksLikeQuestion(msg)) {
      return AssistantParsedQuery(
        intent: AssistantIntentType.queryItemLocation,
        itemName: msg,
      );
    }

    return const AssistantParsedQuery(intent: AssistantIntentType.unknown);
  }

  static bool _containsAny(String msg, List<String> keys) {
    return keys.any(msg.contains);
  }

  static bool _looksLikeQuestion(String msg) {
    return msg.contains('?') || msg.contains('？') || msg.contains('吗');
  }

  /// 「厨房有什么」「卫生间还剩什么」
  static String? _extractSpaceName(String msg) {
    final patterns = [
      RegExp(r'^(.+?)(有什么|还有啥|还剩什么|里有什么|里面有什么|有哪些)$'),
      RegExp(r'^(.+?)(的物品|的东西)$'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(msg);
      if (m != null) {
        final space = m.group(1)?.trim();
        if (space != null && space.isNotEmpty && space.length <= 20) {
          return _stripFillers(space);
        }
      }
    }
    return null;
  }

  /// 「牛奶在哪」「还有牛奶吗」
  static String? _extractItemName(String msg) {
    final patterns = [
      RegExp(r'^(.+?)(在哪|在哪里|在哪儿|放在哪|放哪|的位置)$'),
      RegExp(r'^(还有|有没有)(.+?)(吗|？|\?)?$'),
      RegExp(r'^(.+?)还有吗$'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(msg);
      if (m != null) {
        var name = (m.groupCount >= 2 ? m.group(2) : m.group(1))?.trim();
        if (name == null || name.isEmpty) {
          name = m.group(1)?.trim();
        }
        if (name != null && name.isNotEmpty) {
          name = _stripFillers(name);
          if (name.length <= 30) return name;
        }
      }
    }
    return null;
  }

  static String _stripFillers(String s) {
    return s
        .replaceAll(RegExp(r'^(请问|帮我查|查一下|看看)'), '')
        .replaceAll(RegExp(r'(里的|中的|里面)$'), '')
        .trim();
  }
}
