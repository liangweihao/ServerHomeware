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
import '../common/widgets/cartoon_fab.dart';
import '../common/widgets/cartoon_chip.dart';
import '../common/widgets/cartoon_list_entrance.dart';
import '../common/widgets/cartoon_scaffold.dart';
import '../common/widgets/cartoon_app_bar_icon.dart';
import '../../core/theme/cartoon_copy.dart';
import '../../core/theme/app_visual_style.dart';
import '../../core/theme/cartoon_decorations.dart';
import '../common/widgets/category_selector.dart';
import '../common/widgets/filter_bottom_sheet.dart';
import 'widgets/item_card.dart';

/// 搜索关键�?
final itemSearchQueryProvider = StateProvider<String>((ref) => '');

/// 分类筛选（categoryId�?
final categoryFilterProvider = StateProvider<int?>((ref) => null);

/// 状态筛选（0 使用�?�?3 已丢弃）
final statusFilterProvider = StateProvider<int?>((ref) => null);

/// 仅显示即将过期（与状�?Chip 互斥�?
final expiringSoonFilterProvider = StateProvider<bool>((ref) => false);

/// 位置名称筛选（FilterBottomSheet�?
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

/// 状态文�?�?status 字段
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
        debugPrint('[ItemListPage] INFO: 高级筛选状�?-> $label');
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

    return CartoonScaffold(
      title: '物品',
      titleEmoji: '📦',
      actions: [
        CartoonAppBarIcon(
          icon: Icons.qr_code_scanner_outlined,
          tooltip: '扫码录入',
          onPressed: () {
            debugPrint('[ItemListPage] INFO: 跳转扫码录入');
            context.push('/items/scan');
          },
        ),
      ],
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
                  cartoonKind: CartoonEmptyKind.error,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showScrollToTop
          ? CartoonFloatingActionButton(
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: const Icon(Icons.vertical_align_top, color: Colors.white),
            )
          : CartoonFloatingActionButton(
              onPressed: () => context.push('/items/add'),
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  /// 搜索 + 高级筛选入口（与背景融合，无独立白条）
  Widget _buildSearchHeader(BuildContext context, bool hasExtraFilter) {
    Widget searchField = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '🔍 搜搜看有什么~',
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.primary,
        ),
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
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: (value) {
        ref.read(itemSearchQueryProvider.notifier).state = value;
        setState(() {});
      },
    );

    searchField = Container(
      decoration: CartoonDecorations.stickerCard(
        fillColor: AppColors.white,
        borderColor: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: searchField,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Expanded(child: searchField),
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
              emoji: '🌈',
              isSelected: statusFilter == null && !expiringSoon,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = null;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '使用中',
              emoji: '✅',
              isSelected: statusFilter == 0 && !expiringSoon,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = 0;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已用完',
              emoji: '📭',
              isSelected: statusFilter == 1,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = 1;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已过期',
              emoji: '⏰',
              isSelected: statusFilter == 2,
              onTap: () {
                ref.read(statusFilterProvider.notifier).state = 2;
                ref.read(expiringSoonFilterProvider.notifier).state = false;
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已丢弃',
              emoji: '🗑️',
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

  /// 分类 Chip：点击选分类，× 清除筛�?
  Widget _buildCategoryChip(
    BuildContext context,
    WidgetRef ref,
    String categoryLabel,
    int? categoryFilter,
  ) {
    final isSelected = categoryFilter != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CartoonChip(
          label: isSelected ? categoryLabel : '分类',
          emoji: '🏷️',
          selected: isSelected,
          onTap: _openCategoryPicker,
        ),
        if (isSelected) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              ref.read(categoryFilterProvider.notifier).state = null;
            },
            child: Icon(Icons.close, size: 16, color: AppColors.primaryDark),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? emoji,
  }) {
    return CartoonChip(
      label: label,
      selected: isSelected,
      onTap: onTap,
      emoji: emoji,
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
        cartoonKind: CartoonEmptyKind.search,
        searchQuery: searchQuery,
      );
    }

    return AppEmptyState(
      icon: '📦',
      title: '还没有添加物品',
      subtitle: '扫一扫或手动添加第一件物品吧',
      actionLabel: '+ 添加第一件物品',
      onAction: () => context.push('/items/add'),
      cartoonKind: CartoonEmptyKind.items,
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
        return CartoonListEntrance(
          index: index,
          child: ItemCard(
            item: item,
            locationName: locationName,
            categoryName: categoryMeta?.$1,
            categoryColorHex: categoryMeta?.$2,
            onTap: () => context.push('/items/${item.id}'),
          ),
        );
      },
    );
  }
}
