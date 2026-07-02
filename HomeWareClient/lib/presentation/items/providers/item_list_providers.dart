import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/events/item_event_bus.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/item_sync_service.dart';
import '../../../core/utils/item_list_reason_helper.dart';
import '../../../data/database/app_database.dart';

/// 搜索关键词
final itemSearchQueryProvider = StateProvider<String>((ref) => '');

/// 分类筛选（categoryId）
final categoryFilterProvider = StateProvider<int?>((ref) => null);

/// 状态筛选（0 使用中 … 3 已丢弃）
final statusFilterProvider = StateProvider<int?>((ref) => null);

/// 仅显示即将过期（与状态 Chip 互斥）
final expiringSoonFilterProvider = StateProvider<bool>((ref) => false);

/// 位置名称筛选（FilterBottomSheet）
final locationFilterProvider = StateProvider<String?>((ref) => null);

/// 排序方式 — 默认紧急优先
final itemSortProvider = StateProvider<String>(
  (ref) => AppConstants.sortOptions.first,
);

/// 当前选中的分类名称（展示用）
final categoryFilterLabelProvider = FutureProvider<String>((ref) async {
  final id = ref.watch(categoryFilterProvider);
  if (id == null) return '分类';
  final db = ref.watch(databaseProvider);
  final cat = await db.getCategoryById(id);
  return cat?.name ?? '分类';
});

/// 物品元数据缓存 — 位置路径、分类名/色
class ItemListMeta {
  const ItemListMeta({
    required this.locationNames,
    required this.categoryMeta,
    required this.locationById,
  });

  final Map<int, String> locationNames;
  /// categoryId -> (name, colorHex, icon)
  final Map<int, (String, String, String)> categoryMeta;
  final Map<int, Location> locationById;
}

/// 列表元数据
final itemListMetaProvider = FutureProvider<ItemListMeta>((ref) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  final locations = await db.getAllLocations();
  final categories = await (db.select(db.categories)).get();

  final locationNames = <int, String>{};
  final locationById = <int, Location>{};
  for (final loc in locations) {
    locationNames[loc.id] = loc.fullPath.replaceAll('/', ' › ');
    locationById[loc.id] = loc;
  }

  final categoryMeta = <int, (String, String, String)>{};
  for (final cat in categories) {
    categoryMeta[cat.id] = (cat.name, cat.color, cat.icon);
  }

  return ItemListMeta(
    locationNames: locationNames,
    categoryMeta: categoryMeta,
    locationById: locationById,
  );
});

/// 本地物品数据源 — 同步仅在首次/刷新时执行，供各 Tab 复用
final itemListDataProvider = FutureProvider<List<Item>>((ref) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  await ItemSyncService(db).syncFromServer();
  final items = await db.getAllItems();
  debugPrint('[ItemListProviders] INFO: 本地物品 ${items.length} 件');
  return items;
});

/// 搜索 + 高级筛选后的基础列表（供「全部」Tab）
final filteredItemsProvider = FutureProvider<List<Item>>((ref) async {
  final db = ref.watch(databaseProvider);
  final searchQuery = ref.watch(itemSearchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final expiringSoon = ref.watch(expiringSoonFilterProvider);
  final locationFilter = ref.watch(locationFilterProvider);
  final sort = ref.watch(itemSortProvider);

  List<Item> items = await ref.watch(itemListDataProvider.future);
  items = await _applyCommonFilters(
    items,
    searchQuery: searchQuery,
    categoryFilter: categoryFilter,
    statusFilter: statusFilter,
    expiringSoon: expiringSoon,
    locationFilter: locationFilter,
    db: db,
  );

  items = sortFilteredItems(items, sort);
  return items;
});

/// 仅应用搜索的基础列表（供要处理 / 空间 / 分类 Tab）
final itemListSearchBaseProvider = FutureProvider<List<Item>>((ref) async {
  final searchQuery = ref.watch(itemSearchQueryProvider);
  var items = await ref.watch(itemListDataProvider.future);
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    items = items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          (item.brand?.toLowerCase().contains(query) ?? false);
    }).toList();
  }
  return items;
});

/// 「要处理」— 有过期/库存等理由的物品
final actionItemsProvider = FutureProvider<List<Item>>((ref) async {
  final items = await ref.watch(itemListSearchBaseProvider.future);
  final actionable = items.where((item) {
    final reason = computeItemListReason(item);
    return reason.isActionable && item.status == 0;
  }).toList();
  sortItemsByUrgency(actionable);
  debugPrint('[ItemListProviders] INFO: 要处理 ${actionable.length} 件');
  return actionable;
});

/// 空间分组
class ItemSpaceGroup {
  const ItemSpaceGroup({
    required this.title,
    required this.emoji,
    required this.items,
  });

  final String title;
  final String emoji;
  final List<Item> items;
}

final spaceGroupedItemsProvider = FutureProvider<List<ItemSpaceGroup>>((ref) async {
  final items = await ref.watch(itemListSearchBaseProvider.future);
  final meta = await ref.watch(itemListMetaProvider.future);

  final activeItems = items.where((i) => i.status == 0).toList();
  final groups = <String, List<Item>>{};

  for (final item in activeItems) {
    final groupName = resolveSpaceGroupName(item, meta.locationById);
    groups.putIfAbsent(groupName, () => []).add(item);
  }

  final result = groups.entries.map((entry) {
    final groupItems = List<Item>.from(entry.value)..sort((a, b) => a.name.compareTo(b.name));
    final emoji = _spaceEmojiFor(entry.key, meta);
    return ItemSpaceGroup(title: entry.key, emoji: emoji, items: groupItems);
  }).toList();

  result.sort((a, b) {
    if (a.title == '未指定位置') return 1;
    if (b.title == '未指定位置') return -1;
    return a.title.compareTo(b.title);
  });

  debugPrint('[ItemListProviders] INFO: 空间分组 ${result.length} 组');
  return result;
});

/// 分类分组
class ItemCategoryGroup {
  const ItemCategoryGroup({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.items,
  });

  final int categoryId;
  final String name;
  final String icon;
  final String colorHex;
  final List<Item> items;
}

final categoryGroupedItemsProvider = FutureProvider<List<ItemCategoryGroup>>((ref) async {
  final items = await ref.watch(itemListSearchBaseProvider.future);
  final meta = await ref.watch(itemListMetaProvider.future);

  final activeItems = items.where((i) => i.status == 0).toList();
  final groups = <int, List<Item>>{};

  for (final item in activeItems) {
    groups.putIfAbsent(item.categoryId, () => []).add(item);
  }

  final result = <ItemCategoryGroup>[];
  for (final entry in groups.entries) {
    final catMeta = meta.categoryMeta[entry.key];
    final groupItems = List<Item>.from(entry.value)..sort((a, b) => a.name.compareTo(b.name));
    result.add(
      ItemCategoryGroup(
        categoryId: entry.key,
        name: catMeta?.$1 ?? '未分类',
        icon: catMeta?.$3 ?? '🏷️',
        colorHex: catMeta?.$2 ?? '#FF8A65',
        items: groupItems,
      ),
    );
  }

  result.sort((a, b) => a.name.compareTo(b.name));
  debugPrint('[ItemListProviders] INFO: 分类分组 ${result.length} 组');
  return result;
});

String _spaceEmojiFor(String groupName, ItemListMeta meta) {
  for (final loc in meta.locationById.values) {
    if (loc.fullPath.split('/').first == groupName && loc.icon != null) {
      return loc.icon!;
    }
  }
  if (groupName == '未指定位置') return '❓';
  return '🏠';
}

Future<List<Item>> _applyCommonFilters(
  List<Item> items, {
  required String searchQuery,
  required int? categoryFilter,
  required int? statusFilter,
  required bool expiringSoon,
  required String? locationFilter,
  required AppDatabase db,
}) async {
  if (statusFilter != null) {
    items = items.where((item) => item.status == statusFilter).toList();
  }

  if (expiringSoon) {
    final expiringIds = (await db.getExpiryAlerts()).map((e) => e.id).toSet();
    items = items.where((item) => expiringIds.contains(item.id)).toList();
  }

  if (categoryFilter != null) {
    final childCategories = await db.getChildCategories(categoryFilter);
    final allowedCategoryIds = {
      categoryFilter,
      ...childCategories.map((c) => c.id),
    };
    items = items
        .where((item) => allowedCategoryIds.contains(item.categoryId))
        .toList();
  }

  if (locationFilter != null && locationFilter.isNotEmpty) {
    final locations = await db.getAllLocations();
    final matchedIds = locations
        .where(
          (loc) =>
              loc.name == locationFilter ||
              loc.fullPath.contains(locationFilter),
        )
        .map((loc) => loc.id)
        .toSet();
    items = items
        .where(
          (item) =>
              item.locationId != null && matchedIds.contains(item.locationId),
        )
        .toList();
  }

  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    items = items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          (item.brand?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  return items;
}

/// 排序（含紧急优先）
List<Item> sortFilteredItems(List<Item> items, String sort) {
  final sorted = List<Item>.from(items);
  switch (sort) {
    case '紧急优先':
      sortItemsByUrgency(sorted);
    case '过期时间近→远':
      sorted.sort((a, b) {
        if (a.expiryDate == null && b.expiryDate == null) return 0;
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });
    case '录入时间新→旧':
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case '剩余数量少→多':
      sorted.sort((a, b) => a.currentQuantity.compareTo(b.currentQuantity));
    case '价格高→低':
      sorted.sort((a, b) {
        final pa = a.purchasePrice ?? 0;
        final pb = b.purchasePrice ?? 0;
        return pb.compareTo(pa);
      });
  }
  return sorted;
}
