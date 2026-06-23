import 'package:shared_preferences/shared_preferences.dart';

/// 最近使用的分类 ID（录入页 Chip 第一行，最多 3 个）
class CategoryRecentStorage {
  CategoryRecentStorage._();

  static const _key = 'item_form_recent_category_ids';

  static Future<List<int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map(int.tryParse).whereType<int>().toList();
  }

  static Future<void> record(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    final next = [
      categoryId,
      ...existing.where((id) => id != categoryId),
    ].take(3).toList();
    await prefs.setStringList(
      _key,
      next.map((id) => id.toString()).toList(),
    );
  }
}
