import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/search_provider.dart';
import '../../core/theme/cartoon_copy.dart';
import '../../core/theme/cartoon_decorations.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/cartoon_app_bar_icon.dart';
import '../common/widgets/cartoon_list_entrance.dart';
import '../common/widgets/cartoon_scaffold.dart';
import '../common/widgets/cartoon_ui.dart';
import '../items/widgets/item_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // 自动聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isNotEmpty) {
      addSearchHistory(query.trim());
      ref.invalidate(searchHistoryProvider);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
  }

  /// 卡通主题：贴纸风格搜索�?
  Widget _buildSearchField() {
    final field = TextField(
      controller: _searchController,
      focusNode: _focusNode,
      onChanged: (value) {
        _onSearchChanged(value);
        setState(() {});
      },
      onSubmitted: _onSearchSubmit,
      decoration: InputDecoration(
        hintText: '搜索物品名称、品牌、位置...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.textHint),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text('🔍', style: TextStyle(fontSize: 18)),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
      style: const TextStyle(fontSize: 16),
    );

    return Container(
      decoration: CartoonDecorations.stickerCard(
        fillColor: AppColors.white,
        borderColor: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: field,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final historyAsync = ref.watch(searchHistoryProvider);

    return CartoonScaffold(
      titleWidget: _buildSearchField(),
      actions: [
        if (_searchController.text.isNotEmpty)
          CartoonAppBarIcon(
            icon: Icons.clear,
            tooltip: '清除',
            onPressed: _clearSearch,
          ),
      ],
      body: query.isEmpty
          ? _buildHistoryView(historyAsync)
          : _buildSearchResults(resultsAsync, query),
    );
  }

  Widget _buildHistoryView(AsyncValue<List<String>> historyAsync) {
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: AppEmptyState(
                icon: '🔍',
                title: '搜索历史为空',
                subtitle: '输入关键词开始搜索',
                cartoonKind: CartoonEmptyKind.search,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CartoonUi.pageTitle('搜索历史', emoji: '🕐'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await clearSearchHistory();
                      ref.invalidate(searchHistoryProvider);
                    },
                    child: const Text('清除'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return CartoonListEntrance(
                    index: index,
                    child: ListTile(
                      leading: const Icon(Icons.history, color: AppColors.textHint),
                      title: Text(item),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () async {
                          await removeSearchHistoryItem(item);
                          ref.invalidate(searchHistoryProvider);
                        },
                      ),
                      onTap: () {
                        _searchController.text = item;
                        _searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: item.length),
                        );
                        ref.read(searchQueryProvider.notifier).state = item;
                        setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<dynamic>> resultsAsync, String query) {
    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return AppEmptyState(
            icon: '🔍',
            title: '没有找到 "$query"',
            subtitle: '试试其他关键词？',
            actionLabel: '手动添加 "$query"',
            cartoonKind: CartoonEmptyKind.search,
            searchQuery: query,
            onAction: () {
              context.push('/items/add');
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return CartoonListEntrance(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ItemCard(
                  item: result.item,
                  locationName: result.locationName,
                  onTap: () => context.push('/items/${result.item.id}'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
