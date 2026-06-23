import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/search_provider.dart';
import '../common/widgets/app_empty_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final historyAsync = ref.watch(searchHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchSubmit,
          decoration: InputDecoration(
            hintText: '搜索物品名称、品牌、位置...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
      ),
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
                    '搜索历史',
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
                  return ListTile(
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
                    },
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
            onAction: () {
              // TODO: 跳转到添加物品页面，预填名称
              context.push('/items/add');
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ItemCard(
                item: result.item,
                locationName: result.locationName,
                onTap: () => context.push('/items/${result.item.id}'),
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
