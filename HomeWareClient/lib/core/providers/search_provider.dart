import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../utils/search_utils.dart';
import 'database_provider.dart';

// Re-export databaseProvider for convenience
export 'database_provider.dart' show databaseProvider;

const String _searchHistoryKey = 'search_history';
const int _maxHistoryItems = 10;

// 搜索历史 Provider
final searchHistoryProvider = FutureProvider<List<String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(_searchHistoryKey) ?? [];
});

// 搜索结果
class SearchResult {
  final Item item;
  final String? locationName;

  SearchResult({required this.item, this.locationName});
}

// 搜索结果 Provider（带防抖）
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  final db = ref.watch(databaseProvider);
  final allItems = await db.getAllItems();
  final locations = await db.getAllLocations();
  final locationNameById = {
    for (final loc in locations) loc.id: loc.fullPath,
  };

  final locationNameByItemId = <int, String?>{};
  for (final item in allItems) {
    if (item.locationId != null) {
      locationNameByItemId[item.id] = locationNameById[item.locationId];
    }
  }

  final matches = filterItemsByQuery(
    items: allItems,
    locationNameByItemId: locationNameByItemId,
    query: query,
  );

  return matches
      .map((m) => SearchResult(item: m.item, locationName: m.locationName))
      .toList();
});

/// 输入联想 Provider — 实时前缀/包含匹配
final searchSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 1) return [];

  final db = ref.watch(databaseProvider);
  final allItems = await db.getAllItems();
  return buildSearchSuggestions(items: allItems, query: query);
});

// 添加搜索历史
Future<void> addSearchHistory(String query) async {
  if (query.trim().isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final history = prefs.getStringList(_searchHistoryKey) ?? [];

  history.remove(query);
  history.insert(0, query);

  if (history.length > _maxHistoryItems) {
    history.removeLast();
  }

  await prefs.setStringList(_searchHistoryKey, history);
}

// 清除搜索历史
Future<void> clearSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_searchHistoryKey);
}

// 删除单条搜索历史
Future<void> removeSearchHistoryItem(String query) async {
  final prefs = await SharedPreferences.getInstance();
  final history = prefs.getStringList(_searchHistoryKey) ?? [];
  history.remove(query);
  await prefs.setStringList(_searchHistoryKey, history);
}
