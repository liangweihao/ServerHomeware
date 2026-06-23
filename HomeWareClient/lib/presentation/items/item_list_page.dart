import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/item_sync_service.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/category_selector.dart';
import '../common/widgets/filter_bottom_sheet.dart';
import 'widgets/item_card.dart';

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

/// 排序方式
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

/// 过滤后的物品列表
final filteredItemsProvider = FutureProvider<List<Item>>((ref) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  final searchQuery = ref.watch(itemSearchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);
  final expiringSoon = ref.watch(expiringSoonFilterProvider);
  final locationFilter = ref.watch(locationFilterProvider);
  final sort = ref.watch(itemSortProvider);

  await ItemSyncService(db).syncFromServer();

  List<Item> items = await db.getAllItems();

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

  items = _sortItems(items, sort);
  return items;
});

List<Item> _sortItems(List<Item> items, String sort) {
  final sorted = List<Item>.from(items);
  switch (sort) {
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

/// 状态文案 ↔ status 字段
int? _statusLabelToCode(String? label) {
  switch (label) {
    case '使用中':
      return 0;
    case '已用完':
      return 1;
    case '已过期':
      return 2;
    case '已丢弃':
      return 3;
    default:
      return null;
  }
}

String? _statusCodeToLabel(int? code) {
  switch (code) {
    case 0:
      return '使用中';
    case 1:
      return '已用完';
    case 2:
      return '已过期';
    case 3:
      return '已丢弃';
    default:
      return null;
  }
}

class ItemListPage extends ConsumerStatefulWidget {
  const ItemListPage({super.key});

  @override
  ConsumerState<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends ConsumerState<ItemListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<int, String> _locationNamesCache = {};
  /// categoryId -> (name, colorHex)
  Map<int, (String, String)> _categoryMetaCache = {};
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final showTop = _scrollController.offset > 200;
    if (showTop != _showScrollToTop) {
      setState(() => _showScrollToTop = showTop);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _prefetchLocationNames(List<Item> items) async {
    final locationIds = items
        .where((item) => item.locationId != null)
        .map((item) => item.locationId)
        .whereType<int>()
        .toSet()
        .toList();

    final categoryIds = items.map((item) => item.categoryId).toSet().toList();

    if (locationIds.isEmpty && categoryIds.isEmpty) return;

    final db = ref.read(databaseProvider);
    final locations = locationIds.isNotEmpty ? await db.getAllLocations() : <Location>[];

    final locationCache = <int, String>{};
    for (final location in locations) {
      if (locationIds.contains(location.id)) {
        locationCache[location.id] = location.fullPath;
      }
    }

    final categoryCache = <int, (String, String)>{};
    for (final categoryId in categoryIds) {
      final cat = await db.getCategoryById(categoryId);
      if (cat != null) {
        categoryCache[categoryId] = (cat.name, cat.color);
      }
    }

    if (mounted) {
      setState(() {
        if (locationCache.isNotEmpty) {
          _locationNamesCache = locationCache;
        }
        if (categoryCache.isNotEmpty) {
          _categoryMetaCache = categoryCache;
        }
      });
    }
  }

  Future<void> _openAdvancedFilter() async {
    final statusCode = ref.read(statusFilterProvider);
    final expiringSoon = ref.read(expiringSoonFilterProvider);
    final location = ref.read(locationFilterProvider);
    final sort = ref.read(itemSortProvider);
    final categoryId = ref.read(categoryFilterProvider);

    String? statusLabel;
    if (expiringSoon) {
      statusLabel = '即将过期';
    } else {
      statusLabel = _statusCodeToLabel(statusCode);
    }

    String? categoryLabel;
    if (categoryId != null) {
      final db = ref.read(databaseProvider);
      final cat = await db.getCategoryById(categoryId);
      categoryLabel = cat?.name;
      // FilterBottomSheet 使用一级分类名；子分类映射到父级名
      if (cat != null && cat.parentId != null) {
        final parent = await db.getCategoryById(cat.parentId!);
        if (parent != null &&
            [
              '食品饮料',
              '日用清洁',
              '个护美妆',
              '药品保健',
              '家用电器',
              '其他',
            ].contains(parent.name)) {
          categoryLabel = parent.name;
        }
      }
    }

    if (!mounted) return;

    FilterBottomSheet.show(
      context,
      initialStatus: statusLabel,
      initialLocation: location,
      initialCategory: categoryLabel,
      initialSort: sort,
      onStatusChanged: (label) {
        debugPrint('[ItemListPage] INFO: 高级筛选状态 -> $label');
        if (label == '即将过期') {
          ref.read(expiringSoonFilterProvider.notifier).state = true;
          ref.read(statusFilterProvider.notifier).state = null;
        } else {
          ref.read(expiringSoonFilterProvider.notifier).state = false;
          ref.read(statusFilterProvider.notifier).state = _statusLabelToCode(label);
        }
      },
      onLocationChanged: (loc) {
        ref.read(locationFilterProvider.notifier).state = loc;
      },
      onCategoryChanged: (name) async {
        if (name == null) {
          ref.read(categoryFilterProvider.notifier).state = null;
          return;
        }
        final db = ref.read(databaseProvider);
        final tops = await db.getTopLevelCategories();
        final match = tops.where((c) => c.name == name).firstOrNull;
        ref.read(categoryFilterProvider.notifier).state = match?.id;
      },
      onSortChanged: (value) {
        ref.read(itemSortProvider.notifier).state = value;
      },
    );
  }

  void _openCategoryPicker() {
    CategorySelector.show(
      context,
      onSelected: (category) {
        ref.read(categoryFilterProvider.notifier).state = category.id;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(filteredItemsProvider);
    final categoryLabelAsync = ref.watch(categoryFilterLabelProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final hasExtraFilter = ref.watch(locationFilterProvider) != null ||
        ref.watch(itemSortProvider) != AppConstants.sortOptions.first;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '物品',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.appBarForeground,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            tooltip: '扫码录入',
            onPressed: () {
              debugPrint('[ItemListPage] INFO: 跳转扫码录入');
              context.push('/items/scan');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(context, hasExtraFilter),
          _buildFilterBar(context, ref, categoryLabelAsync, categoryFilter),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(filteredItemsProvider);
              },
              child: itemsAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  _prefetchLocationNames(items);
                  return _buildItemsList(context, items);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => AppEmptyState(
                  icon: '❌',
                  title: '加载失败',
                  subtitle: error.toString(),
                  actionLabel: '重试',
                  onAction: () => ref.invalidate(filteredItemsProvider),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              mini: true,
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.vertical_align_top, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: () => context.push('/items/add'),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  /// 搜索 + 高级筛选入口（与背景融合，无独立白条）
  Widget _buildSearchHeader(BuildContext context, bool hasExtraFilter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索名称、品牌…',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(itemSearchQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.gray100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) {
                ref.read(itemSearchQueryProvider.notifier).state = value;
                setState(() {});
              },
            ),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: hasExtraFilter,
              smallSize: 8,
              child: const Icon(Icons.tune),
            ),
            tooltip: '筛选与排序',
            onPressed: _openAdvancedFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<String> categoryLabelAsync,
    int? categoryFilter,
  ) {
    final statusFilter = ref.watch(statusFilterProvider);
    final expiringSoon = ref.watch(expiringSoonFilterProvider);
    final categoryLabel = categoryLabelAsync.valueOrNull ?? '分类';

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: '全部',
              isSelected: statusFilter == null && !expiringSoon,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = null;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '使用中',
              isSelected: statusFilter == 0 && !expiringSoon,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = 0;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已用完',
              isSelected: statusFilter == 1,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = 1;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已过期',
              isSelected: statusFilter == 2,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = 2;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已丢弃',
              isSelected: statusFilter == 3,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = 3;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildCategoryChip(context, ref, categoryLabel, categoryFilter),
          ],
        ),
      ),
    );
  }

  /// 分类 Chip：点击选分类，× 清除筛选
  Widget _buildCategoryChip(
    BuildContext context,
    WidgetRef ref,
    String categoryLabel,
    int? categoryFilter,
  ) {
    final isSelected = categoryFilter != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLighter : AppColors.gray100,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: AppColors.primary.withOpacity(0.35))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _openCategoryPicker,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSelected ? categoryLabel : '分类',
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 16,
                  color: isSelected ? AppColors.primaryDark : AppColors.textHint,
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                ref.read(categoryFilterProvider.notifier).state = null;
              },
              child: Icon(
                Icons.close,
                size: 14,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLighter : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.primary.withOpacity(0.35))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final searchQuery = ref.watch(itemSearchQueryProvider);

    if (searchQuery.isNotEmpty) {
      return AppEmptyState(
        icon: '🔍',
        title: '没有找到 "$searchQuery"',
        subtitle: '试试其他关键词？',
        actionLabel: '手动添加 "$searchQuery"',
        onAction: () => context.push('/items/add'),
      );
    }

    return AppEmptyState(
      icon: '📦',
      title: '还没有添加物品',
      subtitle: '扫一扫或手动添加第一件物品吧',
      actionLabel: '+ 添加第一件物品',
      onAction: () => context.push('/items/add'),
    );
  }

  Widget _buildItemsList(BuildContext context, List<Item> items) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final locationName = item.locationId != null
            ? _locationNamesCache[item.locationId]
            : null;
        final categoryMeta = _categoryMetaCache[item.categoryId];
        return ItemCard(
          item: item,
          locationName: locationName,
          categoryName: categoryMeta?.$1,
          categoryColorHex: categoryMeta?.$2,
          onTap: () => context.push('/items/${item.id}'),
        );
      },
    );
  }
}
