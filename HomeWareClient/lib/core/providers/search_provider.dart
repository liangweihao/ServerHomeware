import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
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
  
  final results = <SearchResult>[];
  final lowerQuery = query.toLowerCase();
  
  for (final item in allItems) {
    // 检查名称和品牌
    final nameMatch = item.name.toLowerCase().contains(lowerQuery);
    final brandMatch = item.brand?.toLowerCase().contains(lowerQuery) ?? false;
    
    // 检查位置
    String? locationName;
    if (item.locationId != null) {
      final location = await db.getLocationById(item.locationId!);
      locationName = location?.fullPath;
    }
    
    // 检查位置名称
    final locationMatch = locationName?.toLowerCase().contains(lowerQuery) ?? false;
    
    if (nameMatch || brandMatch || locationMatch) {
      results.add(SearchResult(
        item: item,
        locationName: locationName,
      ));
    }
  }
  
  // 按相关度排序（名称匹配优先）
  results.sort((a, b) {
    final aNameMatch = a.item.name.toLowerCase().contains(lowerQuery);
    final bNameMatch = b.item.name.toLowerCase().contains(lowerQuery);
    
    if (aNameMatch && !bNameMatch) return -1;
    if (!aNameMatch && bNameMatch) return 1;
    return 0;
  });
  
  return results;
});

// 添加搜索历史
Future<void> addSearchHistory(String query) async {
  if (query.trim().isEmpty) return;
  
  final prefs = await SharedPreferences.getInstance();
  final history = prefs.getStringList(_searchHistoryKey) ?? [];
  
  // 移除已有的相同项
  history.remove(query);
  
  // 添加到开头
  history.insert(0, query);
  
  // 限制最大数量
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
