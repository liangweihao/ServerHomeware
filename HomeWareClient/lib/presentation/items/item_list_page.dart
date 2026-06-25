import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/item_list_view_tab.dart';
import '../../core/providers/database_provider.dart';
import '../../core/theme/cartoon_copy.dart';
import '../../core/theme/cartoon_decorations.dart';
import '../../core/utils/item_list_reason_helper.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/cartoon_app_bar_icon.dart';
import '../common/widgets/cartoon_chip.dart';
import '../common/widgets/cartoon_bottom_nav.dart';
import '../common/widgets/cartoon_fab.dart';
import '../common/widgets/cartoon_list_entrance.dart';
import '../common/widgets/cartoon_scaffold.dart';
import '../common/widgets/cartoon_tab_bar.dart';
import '../common/widgets/category_selector.dart';
import '../common/widgets/filter_bottom_sheet.dart';
import 'providers/item_list_providers.dart';
import 'widgets/item_grid_masonry.dart';
import 'widgets/item_card.dart';
import 'widgets/item_list_section_header.dart';

class ItemListPage extends ConsumerStatefulWidget {
  const ItemListPage({super.key});

  @override
  ConsumerState<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends ConsumerState<ItemListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

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
    ref.invalidate(filteredItemsProvider);
    ref.invalidate(itemListSearchBaseProvider);
    ref.invalidate(actionItemsProvider);
    ref.invalidate(spaceGroupedItemsProvider);
    ref.invalidate(categoryGroupedItemsProvider);
    ref.invalidate(itemListMetaProvider);
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
    final isAllTab = _tabController.index == ItemListViewTab.all.index;
    final categoryLabelAsync = ref.watch(categoryFilterLabelProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final hasExtraFilter = ref.watch(locationFilterProvider) != null ||
        ref.watch(itemSortProvider) != AppConstants.sortOptions.first;

    final viewTabs = ItemListViewTab.values
        .map(
          (t) => CartoonTabItem(
            label: itemListViewTabLabels[t]!,
            emoji: itemListViewTabEmojis[t],
          ),
        )
        .toList();

    return CartoonScaffold(
      title: '物品',
      titleEmoji: '📦',
      actions: [
        if (_showScrollToTop)
          CartoonAppBarIcon(
            icon: Icons.vertical_align_top,
            tooltip: '回到顶部',
            onPressed: () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
          ),
        CartoonAppBarIcon(
          icon: Icons.qr_code_scanner_outlined,
          tooltip: '扫码录入',
          onPressed: () {
            debugPrint('[ItemListPage] INFO: 跳转扫码录入');
            context.push('/items/scan');
          },
        ),
      ],
      bottom: CartoonTabBar(controller: _tabController, tabs: viewTabs),
      body: Column(
        children: [
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
      floatingActionButton: CartoonFloatingActionButton(
        tooltip: '添加物品',
        onPressed: () {
          debugPrint('[ItemListPage] INFO: 跳转手动添加物品');
          context.push('/items/add');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: CartoonMainTabFabLocation.of(context),
    );
  }

  Widget _buildSearchHeader(bool hasExtraFilter) {
    Widget searchField = TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '🔍 搜搜看有什么~',
        prefixIcon: Icon(Icons.search, color: AppColors.primary),
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
        shadowLevel: CartoonShadowLevel.none,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: searchField,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: [
          Expanded(child: searchField),
          if (_tabController.index == ItemListViewTab.all.index)
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
            _filterChip('全部', '🌈', statusFilter == null && !expiringSoon, () {
              ref.read(statusFilterProvider.notifier).state = null;
              ref.read(expiringSoonFilterProvider.notifier).state = false;
            }),
            const SizedBox(width: 8),
            _filterChip('使用中', '✅', statusFilter == 0 && !expiringSoon, () {
              ref.read(statusFilterProvider.notifier).state = 0;
              ref.read(expiringSoonFilterProvider.notifier).state = false;
            }),
            const SizedBox(width: 8),
            _filterChip('已用完', '📭', statusFilter == 1, () {
              ref.read(statusFilterProvider.notifier).state = 1;
              ref.read(expiringSoonFilterProvider.notifier).state = false;
            }),
            const SizedBox(width: 8),
            _filterChip('已过期', '⏰', statusFilter == 2, () {
              ref.read(statusFilterProvider.notifier).state = 2;
              ref.read(expiringSoonFilterProvider.notifier).state = false;
            }),
            const SizedBox(width: 8),
            _filterChip('已丢弃', '🗑️', statusFilter == 3, () {
              ref.read(statusFilterProvider.notifier).state = 3;
              ref.read(expiringSoonFilterProvider.notifier).state = false;
            }),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CartoonChip(
                  label: categoryFilter != null ? categoryLabel : '分类',
                  emoji: '🏷️',
                  selected: categoryFilter != null,
                  onTap: _openCategoryPicker,
                ),
                if (categoryFilter != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      ref.read(categoryFilterProvider.notifier).state = null;
                    },
                    child: Icon(Icons.close, size: 16, color: AppColors.primaryDark),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    String label,
    String emoji,
    bool selected,
    VoidCallback onTap,
  ) {
    return CartoonChip(
      label: label,
      emoji: emoji,
      selected: selected,
      onTap: onTap,
    );
  }

  Widget _buildActionTab() {
    final itemsAsync = ref.watch(actionItemsProvider);
    final metaAsync = ref.watch(itemListMetaProvider);

    return _asyncTabBody(
      itemsAsync: itemsAsync,
      metaAsync: metaAsync,
      onRefresh: _invalidateAll,
      empty: const AppEmptyState(
        icon: '😊',
        title: '一切安好',
        subtitle: '没有需要立即处理的物品',
        cartoonKind: CartoonEmptyKind.items,
      ),
      builder: (items, meta) => ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16 + _fabClearance),
        itemCount: items.length,
        itemBuilder: (context, index) => CartoonListEntrance(
          index: index,
          child: _buildItemCard(
            items[index],
            meta,
            layout: ItemCardLayout.reasonFirst,
          ),
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    final itemsAsync = ref.watch(filteredItemsProvider);
    final metaAsync = ref.watch(itemListMetaProvider);

    return _asyncTabBody(
      itemsAsync: itemsAsync,
      metaAsync: metaAsync,
      onRefresh: _invalidateAll,
      empty: _buildGenericEmpty(),
      builder: (items, meta) => ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16 + _fabClearance),
        itemCount: items.length,
        itemBuilder: (context, index) => CartoonListEntrance(
          index: index,
          child: _buildItemCard(
            items[index],
            meta,
            layout: ItemCardLayout.reasonFirst,
          ),
        ),
      ),
    );
  }

  Widget _buildSpaceTab() {
    final groupsAsync = ref.watch(spaceGroupedItemsProvider);
    final metaAsync = ref.watch(itemListMetaProvider);

    return RefreshIndicator(
      onRefresh: () async => _invalidateAll(),
      child: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorState(e.toString()),
        data: (groups) {
          if (groups.isEmpty) {
            return _buildGenericEmpty();
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
                    ItemGridMasonry(
                      items: group.items,
                      itemBuilder: (item, index) => CartoonListEntrance(
                        index: index,
                        child: _buildItemCard(
                          item,
                          meta,
                          layout: ItemCardLayout.grid,
                        ),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorState(e.toString()),
        data: (groups) {
          if (groups.isEmpty) {
            return _buildGenericEmpty();
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
                    ItemGridMasonry(
                      items: group.items,
                      itemBuilder: (item, index) => CartoonListEntrance(
                        index: index,
                        child: _buildItemCard(
                          item,
                          meta,
                          layout: ItemCardLayout.grid,
                        ),
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

  Widget _asyncTabBody({
    required AsyncValue<List<Item>> itemsAsync,
    required AsyncValue<ItemListMeta> metaAsync,
    required VoidCallback onRefresh,
    required Widget empty,
    required Widget Function(List<Item> items, ItemListMeta meta) builder,
  }) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorState(e.toString()),
        data: (items) {
          if (items.isEmpty) return empty;
          return metaAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorState(e.toString()),
            data: (meta) => builder(items, meta),
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

  Widget _errorState(String message) {
    return AppEmptyState(
      icon: '❌',
      title: '加载失败',
      subtitle: message,
      actionLabel: '重试',
      onAction: _invalidateAll,
      cartoonKind: CartoonEmptyKind.error,
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
