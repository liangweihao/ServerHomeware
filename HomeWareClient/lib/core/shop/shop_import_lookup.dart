import '../../data/database/app_database.dart';

/// 分类/位置名称 → 本地 ID 查找表
class ShopImportLookup {
  ShopImportLookup({
    required this.categoriesByName,
    required this.locationsByPath,
    required this.locationsByName,
    required this.defaultCategoryId,
    this.defaultLocationId,
  });

  final Map<String, Category> categoriesByName;
  final Map<String, Location> locationsByPath;
  final Map<String, Location> locationsByName;
  final int defaultCategoryId;
  final int? defaultLocationId;

  /// 从本地 DB 构建查找表
  static Future<ShopImportLookup> fromDatabase(AppDatabase db) async {
    final categories = await db.getAllCategoriesFlat();
    final locations = await db.getAllLocations();

    final catMap = <String, Category>{};
    for (final c in categories) {
      catMap[c.name.trim().toLowerCase()] = c;
    }

    final pathMap = <String, Location>{};
    final nameMap = <String, Location>{};
    for (final l in locations) {
      pathMap[l.fullPath.trim().toLowerCase()] = l;
      nameMap.putIfAbsent(l.name.trim().toLowerCase(), () => l);
    }

    final defaultCat = categories.firstWhere(
      (c) => c.name == '其他',
      orElse: () => categories.first,
    );

    Location? defaultLoc;
    for (final l in locations) {
      if (l.fullPath.contains('店面')) {
        defaultLoc = l;
        break;
      }
    }
    defaultLoc ??= locations.isNotEmpty ? locations.first : null;

    return ShopImportLookup(
      categoriesByName: catMap,
      locationsByPath: pathMap,
      locationsByName: nameMap,
      defaultCategoryId: defaultCat.id,
      defaultLocationId: defaultLoc?.id,
    );
  }

  int resolveCategoryId(String? name) {
    if (name == null || name.trim().isEmpty) return defaultCategoryId;
    return categoriesByName[name.trim().toLowerCase()]?.id ??
        defaultCategoryId;
  }

  int? resolveLocationId(String? name) {
    if (name == null || name.trim().isEmpty) return defaultLocationId;
    final key = name.trim().toLowerCase();
    return locationsByPath[key]?.id ??
        locationsByName[key]?.id ??
        defaultLocationId;
  }
}
