import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/search_constants.dart';
import '../../core/providers/search_provider.dart';
import '../../core/utils/item_list_reason_helper.dart';
import '../common/widgets/async_list_body.dart';
import '../common/widgets/warm_scaffold.dart';
import '../items/widgets/item_card.dart';
import 'widgets/item_alert_link_banner.dart';
import 'widgets/item_location_link_banner.dart';
import 'widgets/search_recommend_sections.dart';

/// 搜索页 — 历史 + 热词 + 推荐分区 + 结果（Phase1 暖色改造）
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  int _placeholderIndex = 0;
  Timer? _placeholderTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _placeholderIndex =
            (_placeholderIndex + 1) % SearchConstants.searchPlaceholders.length;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    _placeholderTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  void _applyQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    ref.read(searchQueryProvider.notifier).state = query;
    addSearchHistory(query);
    ref.invalidate(searchHistoryProvider);
    setState(() {});
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isNotEmpty) {
      _applyQuery(query.trim());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {});
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.homeDivider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: AppColors.textHint),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (v) {
                _onSearchChanged(v);
                setState(() {});
              },
              onSubmitted: _onSearchSubmit,
              decoration: InputDecoration(
                hintText: SearchConstants.searchPlaceholders[_placeholderIndex],
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: _clearSearch,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);
    final historyAsync = ref.watch(searchHistoryProvider);

    return WarmScaffold(
      titleWidget: _buildSearchField(),
      body: query.isEmpty
          ? _buildIdleView(historyAsync)
          : _buildSearchResults(resultsAsync, query),
    );
  }

  Widget _buildIdleView(AsyncValue<List<String>> historyAsync) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          historyAsync.when(
            data: (history) => _buildHistorySection(history),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          _buildHotKeywords(),
          const SearchRecommendSections(),
        ],
      ),
    );
  }

  Widget _buildHistorySection(List<String> history) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '搜索历史',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () async {
                  await clearSearchHistory();
                  ref.invalidate(searchHistoryProvider);
                },
                child: const Text('清空'),
              ),
            ],
          ),
          Wrap(
            spacing: SearchConstants.chipSpacing,
            runSpacing: SearchConstants.chipSpacing,
            children: history.map((item) {
              return ActionChip(
                label: Text(item),
                onPressed: () => _applyQuery(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHotKeywords() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '热门搜索',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: SearchConstants.chipSpacing,
            runSpacing: SearchConstants.chipSpacing,
            children: SearchConstants.hotKeywords.map((word) {
              return FilterChip(
                label: Text(word),
                selected: false,
                onSelected: (_) => _applyQuery(word),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    AsyncValue<List<SearchResult>> resultsAsync,
    String query,
  ) {
    final suggestionsAsync = ref.watch(searchSuggestionsProvider);

    return Column(
      children: [
        ItemAlertLinkBanner(query: query),
        ItemLocationLinkBanner(query: query),
        suggestionsAsync.when(
          data: (suggestions) => _buildSuggestionsBar(suggestions, query),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(
          child: resultsAsync.when(
            data: (results) {
              return AsyncListBody(
                isLoading: false,
                isEmpty: results.isEmpty,
                emptyIcon: Icons.search_off,
                emptyTitle: '没有找到 "$query"',
                emptySubtitle: '试试其他关键词',
                emptyActionLabel: '手动添加',
                onEmptyAction: () => context.push(
                  '/items/add?name=${Uri.encodeComponent(query)}',
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ItemCard(
                      item: result.item,
                      locationName: result.locationName,
                      layout: ItemCardLayout.reasonFirst,
                      reason: computeItemListReason(result.item),
                      onTap: () => context.push('/items/${result.item.id}'),
                    );
                  },
                ),
              );
            },
            loading: () => const AsyncListBody(
              isLoading: true,
              isEmpty: false,
              emptyIcon: Icons.search,
              emptyTitle: '',
              child: SizedBox.shrink(),
            ),
            error: (error, _) => AsyncListBody(
              isLoading: false,
              isEmpty: false,
              errorMessage: '$error',
              onRetry: () => ref.invalidate(searchResultsProvider),
              emptyIcon: Icons.error,
              emptyTitle: '',
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  /// 输入联想条 — 点击快速选中
  Widget _buildSuggestionsBar(List<String> suggestions, String query) {
    final filtered = suggestions
        .where((s) => s.toLowerCase() != query.toLowerCase())
        .toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '搜索建议',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final word = filtered[index];
                return ActionChip(
                  label: Text(word),
                  onPressed: () => _applyQuery(word),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
