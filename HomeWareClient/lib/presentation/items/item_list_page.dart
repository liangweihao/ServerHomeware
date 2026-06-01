import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/item_sync_service.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_empty_state.dart';
import 'widgets/item_card.dart';

// 搜索关键词 Provider
final itemSearchQueryProvider = StateProvider<String>((ref) => '');

// 分类筛选 Provider
final categoryFilterProvider = StateProvider<int?>((ref) => null);

// 状态筛选 Provider
final statusFilterProvider = StateProvider<int?>((ref) => null);

// 过滤后的物品列表
final filteredItemsProvider = FutureProvider<List<Item>>((ref) async {
  // 监听事件总线版本号，创建/更新/删除/丢弃等任何变更自动触发重新查询
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  final searchQuery = ref.watch(itemSearchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  // 从服务端同步物品到本地（缓存清理后可恢复）
  await ItemSyncService(db).syncFromServer();

  List<Item> items = await db.getAllItems();

  // 应用状态筛选
  if (statusFilter != null) {
    items = items.where((item) => item.status == statusFilter).toList();
  }

  // 应用分类筛选
  if (categoryFilter != null) {
    items = items.where((item) => item.categoryId == categoryFilter).toList();
  }

  // 应用搜索筛选
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    items = items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          (item.brand?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  return items;
});

class ItemListPage extends ConsumerStatefulWidget {
  const ItemListPage({super.key});

  @override
  ConsumerState<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends ConsumerState<ItemListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<int, String> _locationNamesCache = {};

  @override
  void dispose() {
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

    if (locationIds.isEmpty) return;

    final db = ref.read(databaseProvider);
    final locations = await db.getAllLocations();

    final cache = <int, String>{};
    for (final location in locations) {
      if (locationIds.contains(location.id)) {
        cache[location.id] = location.fullPath;
      }
    }

    if (mounted) {
      setState(() {
        _locationNamesCache = cache;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(filteredItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.card,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索物品名称、品牌...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(itemSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  ref.read(itemSearchQueryProvider.notifier).state = value;
                },
              ),
            ),

            // 筛选栏
            _buildFilterBar(context, ref),

            // 物品列表
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
                    // 预加载位置名称
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
      ),
      floatingActionButton: _scrollController.hasClients && _scrollController.offset > 200
          ? FloatingActionButton(
              onPressed: () => _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
              backgroundColor: AppColors.primary,
              mini: true,
              child: const Icon(Icons.vertical_align_top, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: () => context.push('/items/add'),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(statusFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.card,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: '全部',
              isSelected: statusFilter == null,
              onTap: () => ref.read(statusFilterProvider.notifier).state = null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '使用中',
              isSelected: statusFilter == 0,
              onTap: () => ref.read(statusFilterProvider.notifier).state = 0,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已用完',
              isSelected: statusFilter == 1,
              onTap: () => ref.read(statusFilterProvider.notifier).state = 1,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已过期',
              isSelected: statusFilter == 2,
              onTap: () => ref.read(statusFilterProvider.notifier).state = 2,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '已丢弃',
              isSelected: statusFilter == 3,
              onTap: () => ref.read(statusFilterProvider.notifier).state = 3,
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final searchQuery = ref.watch(itemSearchQueryProvider);

    if (searchQuery.isNotEmpty) {
      // 搜索无结果
      return AppEmptyState(
        icon: '🔍',
        title: '没有找到 "$searchQuery"',
        subtitle: '试试其他关键词？',
        actionLabel: '手动添加 "$searchQuery"',
        onAction: () {
          context.push('/items/add');
        },
      );
    }

    // 物品列表为空
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
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        // 使用缓存的位置名称
        final locationName = item.locationId != null
            ? _locationNamesCache[item.locationId]
            : null;
        return ItemCard(
          item: item,
          locationName: locationName,
          onTap: () => context.push('/items/${item.id}'),
        );
      },
    );
  }
}
