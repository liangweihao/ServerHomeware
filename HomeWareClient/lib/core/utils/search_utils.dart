import '../../data/database/app_database.dart';

/// 搜索匹配结果（纯逻辑，便于单测）
class SearchMatch {
  const SearchMatch({
    required this.item,
    this.locationName,
    required this.nameMatch,
  });

  final Item item;
  final String? locationName;
  final bool nameMatch;
}

/// 按关键词过滤物品（名称 / 品牌 / 位置）
List<SearchMatch> filterItemsByQuery({
  required List<Item> items,
  required Map<int, String?> locationNameByItemId,
  required String query,
  int? limit,
}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return [];

  final lowerQuery = trimmed.toLowerCase();
  final results = <SearchMatch>[];

  for (final item in items) {
    final locationName = locationNameByItemId[item.id];

    final nameMatch = item.name.toLowerCase().contains(lowerQuery);
    final brandMatch = item.brand?.toLowerCase().contains(lowerQuery) ?? false;
    final locationMatch =
        locationName?.toLowerCase().contains(lowerQuery) ?? false;

    if (nameMatch || brandMatch || locationMatch) {
      results.add(SearchMatch(
        item: item,
        locationName: locationName,
        nameMatch: nameMatch,
      ));
    }
  }

  results.sort((a, b) {
    if (a.nameMatch && !b.nameMatch) return -1;
    if (!a.nameMatch && b.nameMatch) return 1;
    return a.item.name.compareTo(b.item.name);
  });

  if (limit != null && results.length > limit) {
    return results.sublist(0, limit);
  }
  return results;
}

/// 搜索联想：前缀/包含匹配的物品名（去重）
List<String> buildSearchSuggestions({
  required List<Item> items,
  required String query,
  int limit = 8,
}) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return [];

  final lower = trimmed.toLowerCase();
  final names = <String>{};

  for (final item in items) {
    final name = item.name;
    final lowerName = name.toLowerCase();
    if (lowerName.contains(lower) || lowerName.startsWith(lower)) {
      names.add(name);
      if (names.length >= limit) break;
    }
  }

  return names.take(limit).toList();
}
