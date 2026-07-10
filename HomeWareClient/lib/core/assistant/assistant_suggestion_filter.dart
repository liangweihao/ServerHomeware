/// 问管管 — 过滤 `**加粗**` 中哪些可点击追问（排除购物清单等无效片段）
abstract final class AssistantSuggestionFilter {
  /// 购物清单 / 标题类加粗 — 不可点击、不展示 Pill
  static bool isActionable(String segment) {
    final s = segment.trim();
    if (s.isEmpty || s.length < 2) return false;
    if (s.contains('购物清单')) return false;
    if (s.endsWith('：') || s.endsWith(':')) return false;
    final sepCount =
        '、'.allMatches(s).length + '，'.allMatches(s).length + ','.allMatches(s).length;
    if (sepCount >= 2) return false;
    if (s.length > 24 && sepCount >= 1) return false;
    return true;
  }

  /// 去掉括号备注，如「十斤羊肉（未指定位置）」→「十斤羊肉」
  static String normalizeName(String segment) {
    var s = segment.trim();
    s = s.replaceAll(RegExp(r'（[^）]*）'), '');
    s = s.replaceAll(RegExp(r'\([^)]*\)'), '');
    return s.trim();
  }

  /// 点击后发送的追问文案
  static String tapQuery(String segment) {
    final name = normalizeName(segment);
    if (name.contains('在哪') || name.contains('有没有')) return name;
    return '$name在哪里';
  }

  /// 从全文提取可操作的加粗词（去重、已规范化展示名）
  static List<String> extractActionable(String raw) {
    if (!raw.contains('**')) return const [];
    final parts = raw.split('**');
    final seen = <String>{};
    final result = <String>[];
    for (var i = 1; i < parts.length; i += 2) {
      final segment = parts[i].trim();
      if (!isActionable(segment)) continue;
      final name = normalizeName(segment);
      if (name.isEmpty || seen.contains(name)) continue;
      seen.add(name);
      result.add(name);
    }
    return result;
  }
}
