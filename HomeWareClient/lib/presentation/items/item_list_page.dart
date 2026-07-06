import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/item_list_constants.dart';
import '../../core/models/item_list_view_tab.dart';
import '../../core/providers/database_provider.dart';
import '../../core/utils/item_list_reason_helper.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/async_list_body.dart';
import '../common/widgets/category_selector.dart';
import '../common/widgets/filter_bottom_sheet.dart';
import '../common/widgets/filter_chip_bar.dart';
import '../common/widgets/warm_scaffold.dart';
import 'providers/item_list_providers.dart';
import 'providers/item_list_pagination.dart';
import 'widgets/paginated_grid_section.dart';
import 'widgets/item_card.dart';
import 'widgets/item_list_section_header.dart';

class ItemListPage extends ConsumerStatefulWidget {
  const ItemListPage({
    super.key,
    this.initialLocationFilter,
    this.initialTab,
  });

  /// 路由 query `location` — 预填位置筛选
  final String? initialLocationFilter;

  /// 路由 query `tab` — 如 space / all / action
  final String? initialTab;

  @override
  ConsumerState<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends ConsumerState<ItemListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _appliedRouteIntent = false;

  static const _statusChipLabels = ['全部', '使用中', '已用完', '已过期', '已丢弃'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: ItemListViewTab.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      debugPrint(
        '[ItemListPage] INFO: 切换视图 -> ${ItemListViewTab.values[_tabController.index].name}',
      );
      setState(() {});
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final showTop = _scrollController.offset > 200;
    if (showTop != _showScrollToTop) {
      setState(() => _showScrollToTop = showTop);
    }
    _maybeLoadMoreOnScroll();
  }

  /// 接近底部时自动加载下一页（列表 Tab）
  void _maybeLoadMoreOnScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent - pos.pixels > ItemListConstants.loadMoreThreshold) {
      return;
    }

    final tab = ItemListViewTab.values[_tabController.index];
    switch (tab) {
      case ItemListViewTab.action:
        ref.read(actionItemsPaginatedProvider.notifier).loadMore();
      case ItemListViewTab.all:
        ref.read(allItemsPaginatedProvider.notifier).loadMore();
      case ItemListViewTab.space:
      case ItemListViewTab.category:
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _invalidateAll() {
    ref.invalidate(itemListDataProvider);
    ref.invalidate(filteredItemsProvider);
    ref.invalidate(itemListSearchBaseProvider);
    ref.invalidate(actionItemsProvider);
    ref.invalidate(spaceGroupedItemsProvider);
    ref.invalidate(categoryGroupedItemsProvider);
    ref.invalidate(itemListMetaProvider);
    ref.invalidate(actionItemsPaginatedProvider);
    ref.invalidate(allItemsPaginatedProvider);
  }

  /// 列表底部留白，避免最后一项被 FAB 遮挡
  static const _fabClearance = 72.0;

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
    _applyRouteIntentOnce();

    final isAllTab = _tabController.index == ItemListViewTab.all.index;
    final categoryLabelAsync = ref.watch(categoryFilterLabelProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final hasExtraFilter = ref.watch(locationFilterProvider) != null ||
        ref.watch(itemSortProvider) != AppConstants.sortOptions.first;

    final viewTabs = ItemListViewTab.values
        .map((t) => Tab(text: itemListViewTabLabels[t]))
        .toList();

    return WarmScaffold(
      title: '物品',
      actions: [
        if (_showScrollToTop)
          IconButton(
            icon: const CandyIcon(Icons.vertical_align_top),
            tooltip: '回到顶部',
            onPressed: () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
          ),
        IconButton(
          icon: const CandyIcon(Icons.qr_code_scanner_outlined),
          tooltip: '扫码录入',
          onPressed: () {
            debugPrint('[ItemListPage] INFO: 跳转扫码录入');
            context.push('/items/scan');
          },
        ),
      ],
      body: Column(
        children: [
          Material(
            color: AppColors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: viewTabs,
            ),
          ),
          _buildSearchHeader(hasExtraFilter && isAllTab),
          if (isAllTab)
            _buildFilterBar(categoryLabelAsync, categoryFilter),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActionTab(),
                _buildSpaceTab(),
                _buildCategoryTab(),
                _buildAllTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加物品',
        onPressed: () {
          debugPrint('[ItemListPage] INFO: 跳转手动添加物品');
          context.push('/items/add/method');
        },
        child: const CandyIcon(Icons.add),
      ),
    );
  }

  /// 应用路由 query 中的 tab / location 筛选（仅一次）
  void _applyRouteIntentOnce() {
    if (_appliedRouteIntent) return;
    final hasLocation = widget.initialLocationFilter?.isNotEmpty == true;
    final hasTab = widget.initialTab?.isNotEmpty == true;
    if (!hasLocation && !hasTab) return;

    _appliedRouteIntent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasLocation) {
        ref.read(locationFilterProvider.notifier).state =
            widget.initialLocationFilter;
        debugPrint(
          '[ItemListPage] INFO: 应用位置筛选 ${widget.initialLocationFilter}',
        );
      }
      if (hasTab) {
        final tabIndex = _resolveTabIndex(widget.initialTab!);
        if (tabIndex != null && _tabController.index != tabIndex) {
          _tabController.index = tabIndex;
          debugPrint('[ItemListPage] INFO: 切换 Tab index=$tabIndex');
        }
      }
      if (mounted) setState(() {});
    });
  }

  int? _resolveTabIndex(String tab) {
    switch (tab) {
      case 'action':
        return ItemListViewTab.action.index;
      case 'space':
        return ItemListViewTab.space.index;
      case 'category':
        return ItemListViewTab.category.index;
      case 'all':
        return ItemListViewTab.all.index;
      default:
        return null;
    }
  }

  Widget _buildSearchHeader(bool hasExtraFilter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.homeDivider),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CandyIcon(Icons.search, size: 20, color: AppColors.textHint),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '搜索物品名称、位置',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const CandyIcon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(itemSearchQueryProvider.notifier).state =
                                      '';
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        ref.read(itemSearchQueryProvider.notifier).state = value;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_tabController.index == ItemListViewTab.all.index)
            IconButton(
              icon: Badge(
                isLabelVisible: hasExtraFilter,
                smallSize: 8,
                child: const CandyIcon(Icons.tune),
              ),
              tooltip: '筛选与排序',
              onPressed: _openAdvancedFilter,
            ),
        ],
      ),
    );
  }

  int _statusChipSelectedIndex(int? statusFilter, bool expiringSoon) {
    if (expiringSoon) return 0;
    switch (statusFilter) {
      case 0:
        return 1;
      case 1:
        return 2;
      case 2:
        return 3;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  void _onStatusChipSelected(int index) {
    ref.read(expiringSoonFilterProvider.notifier).state = false;
    switch (index) {
      case 0:
        ref.read(statusFilterProvider.notifier).state = null;
      case 1:
        ref.read(statusFilterProvider.notifier).state = 0;
      case 2:
        ref.read(statusFilterProvider.notifier).state = 1;
      case 3:
        ref.read(statusFilterProvider.notifier).state = 2;
      case 4:
        ref.read(statusFilterProvider.notifier).state = 3;
    }
    debugPrint('[ItemListPage] INFO: 状态 Chip -> ${_statusChipLabels[index]}');
  }

  Widget _buildFilterBar(
    AsyncValue<String> categoryLabelAsync,
    int? categoryFilter,
  ) {
    final statusFilter = ref.watch(statusFilterProvider);
    final expiringSoon = ref.watch(expiringSoonFilterProvider);
    final categoryLabel = categoryLabelAsync.valueOrNull ?? '分类';

    return Column(
      children: [
        FilterChipBar(
          labels: _statusChipLabels,
          selectedIndex: _statusChipSelectedIndex(statusFilter, expiringSoon),
          onSelected: _onStatusChipSelected,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              FilterChip(
                label: Text(categoryFilter != null ? categoryLabel : '分类'),
                selected: categoryFilter != null,
                onSelected: (_) => _openCategoryPicker(),
              ),
              if (categoryFilter != null)
                IconButton(
                  icon: const CandyIcon(Icons.close, size: 18),
                  onPressed: () {
                    ref.read(categoryFilterProvider.notifier).state = null;
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTab() {
    final pageAsync = ref.watch(actionItemsPaginatedProvider);
    final metaAsync = ref.watch(itemListMetaProvider);

    return _paginatedTabBody(
      pageAsync: pageAsync,
      metaAsync: metaAsync,
      onRefresh: _invalidateAll,
      empty: AsyncListBody(
        isLoading: false,
        isEmpty: true,
        emptyIcon: Icons.check_circle_outline,
        emptyTitle: '一切安好',
        emptySubtitle: '没有需要立即处理的物品',
        child: const SizedBox.shrink(),
      ),
      itemBuilder: (item, index, meta) => _buildItemCard(
        item,
        meta,
        layout: ItemCardLayout.reasonFirst,
      ),
    );
  }

  Widget _buildAllTab() {
    final pageAsync = ref.watch(allItemsPaginatedProvider);
    final metaAsync = ref.watch(itemListMetaProvider);

    return _paginatedTabBody(
      pageAsync: pageAsync,
      metaAsync: metaAsync,
      onRefresh: _invalidateAll,
      empty: _buildGenericEmpty(),
      itemBuilder: (item, index, meta) => _buildItemCard(
        item,
        meta,
        layout: ItemCardLayout.reasonFirst,
      ),
    );
  }

  Widget _buildSpaceTab() {
    final groupsAsync = ref.watch(spaceGroupedItemsProvider);
    final metaAsync = ref.watch(itemListMetaProvider);

    return RefreshIndicator(
      onRefresh: () async => _invalidateAll(),
      child: groupsAsync.when(
        loading: () => const AsyncListBody(
          isLoading: true,
          isEmpty: false,
          emptyIcon: Icons.inventory_2_outlined,
          emptyTitle: '',
          child: SizedBox.shrink(),
        ),
        error: (e, _) => AsyncListBody(
          isLoading: false,
          isEmpty: false,
          errorMessage: e.toString(),
          onRetry: _invalidateAll,
          emptyIcon: Icons.error_outline,
          emptyTitle: '',
          child: const SizedBox.shrink(),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [_buildGenericEmpty()],
            );
          }
          return metaAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorState(e.toString()),
            data: (meta) => ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16 + _fabClearance),
              itemCount: groups.length,
              itemBuilder: (context, gi) {
                final group = groups[gi];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemListSectionHeader(
                      title: group.title,
                      emoji: group.emoji,
                      count: group.items.length,
                    ),
                    PaginatedGridSection(
                      groupKey: group.title,
                      allItems: group.items,
                      itemBuilder: (item, index) => _buildItemCard(
                        item,
                        meta,
                        layout: ItemCardLayout.grid,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab() {
    final groupsAsync = ref.watch(categoryGroupedItemsProvider);
    final metaAsync = ref.watch(itemListMetaProvider);

    return RefreshIndicator(
      onRefresh: () async => _invalidateAll(),
      child: groupsAsync.when(
        loading: () => const AsyncListBody(
          isLoading: true,
          isEmpty: false,
          emptyIcon: Icons.category_outlined,
          emptyTitle: '',
          child: SizedBox.shrink(),
        ),
        error: (e, _) => AsyncListBody(
          isLoading: false,
          isEmpty: false,
          errorMessage: e.toString(),
          onRetry: _invalidateAll,
          emptyIcon: Icons.error_outline,
          emptyTitle: '',
          child: const SizedBox.shrink(),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [_buildGenericEmpty()],
            );
          }
          return metaAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorState(e.toString()),
            data: (meta) => ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16 + _fabClearance),
              itemCount: groups.length,
              itemBuilder: (context, gi) {
                final group = groups[gi];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ItemListSectionHeader(
                      title: group.name,
                      emoji: group.icon,
                      count: group.items.length,
                    ),
                    PaginatedGridSection(
                      groupKey: 'cat-${group.categoryId}',
                      allItems: group.items,
                      itemBuilder: (item, index) => _buildItemCard(
                        item,
                        meta,
                        layout: ItemCardLayout.grid,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _paginatedTabBody({
    required AsyncValue<PaginatedItemsState> pageAsync,
    required AsyncValue<ItemListMeta> metaAsync,
    required VoidCallback onRefresh,
    required Widget empty,
    required Widget Function(Item item, int index, ItemListMeta meta)
        itemBuilder,
  }) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: pageAsync.when(
        loading: () => const AsyncListBody(
          isLoading: true,
          isEmpty: false,
          emptyIcon: Icons.inventory_2_outlined,
          emptyTitle: '',
          child: SizedBox.shrink(),
        ),
        error: (e, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AsyncListBody(
              isLoading: false,
              isEmpty: false,
              errorMessage: e.toString(),
              onRetry: onRefresh,
              emptyIcon: Icons.error_outline,
              emptyTitle: '',
              child: const SizedBox.shrink(),
            ),
          ],
        ),
        data: (page) {
          if (page.totalCount == 0) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [empty],
            );
          }
          return metaAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorState(e.toString()),
            data: (meta) => ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16 + _fabClearance),
              itemCount: page.items.length + (page.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= page.items.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: page.isLoadingMore
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              '已显示 ${page.items.length}/${page.totalCount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textHint),
                            ),
                    ),
                  );
                }
                return itemBuilder(page.items[index], index, meta);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(
    Item item,
    ItemListMeta meta, {
    required ItemCardLayout layout,
  }) {
    final locationName =
        item.locationId != null ? meta.locationNames[item.locationId] : null;
    final category = meta.categoryMeta[item.categoryId];

    return ItemCard(
      item: item,
      locationName: locationName,
      categoryName: category?.$1,
      categoryColorHex: category?.$2,
      layout: layout,
      reason: computeItemListReason(item),
      onTap: () => context.push('/items/${item.id}'),
    );
  }

  Widget _buildGenericEmpty() {
    final searchQuery = ref.watch(itemSearchQueryProvider);
    if (searchQuery.isNotEmpty) {
      return AsyncListBody(
        isLoading: false,
        isEmpty: true,
        emptyIcon: Icons.search_off,
        emptyTitle: '没有找到 "$searchQuery"',
        emptySubtitle: '试试其他关键词？',
        emptyActionLabel: '手动添加 "$searchQuery"',
        onEmptyAction: () => context.push('/items/add/method'),
        child: const SizedBox.shrink(),
      );
    }
    return AsyncListBody(
      isLoading: false,
      isEmpty: true,
      emptyIcon: Icons.inventory_2_outlined,
      emptyTitle: '还没有添加物品',
      emptySubtitle: '扫一扫或手动添加第一件物品吧',
      emptyActionLabel: '添加入库',
      onEmptyAction: () => context.push('/items/add/method'),
      child: const SizedBox.shrink(),
    );
  }

  Widget _errorState(String message) {
    return AsyncListBody(
      isLoading: false,
      isEmpty: false,
      errorMessage: message,
      onRetry: _invalidateAll,
      emptyIcon: Icons.error_outline,
      emptyTitle: '',
      child: const SizedBox.shrink(),
    );
  }
}

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
