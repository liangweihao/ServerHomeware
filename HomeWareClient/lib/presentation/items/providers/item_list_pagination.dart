import 'dart:math' as math;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/item_list_constants.dart';
import '../../../core/events/item_event_bus.dart';
import '../../../core/utils/item_list_reason_helper.dart';
import '../../../data/database/app_database.dart';
import 'item_list_providers.dart';

/// 分页列表 UI 状态
class PaginatedItemsState {
  const PaginatedItemsState({
    required this.items,
    required this.totalCount,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  /// 当前已展示的物品
  final List<Item> items;

  /// 筛选后总条数
  final int totalCount;

  /// 是否还有未展示的数据
  final bool hasMore;

  /// 正在加载下一页
  final bool isLoadingMore;

  PaginatedItemsState copyWith({
    List<Item>? items,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedItemsState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

PaginatedItemsState _toPaginatedState(List<Item> source, int visibleCount) {
  final end = math.min(visibleCount, source.length);
  return PaginatedItemsState(
    items: source.sublist(0, end),
    totalCount: source.length,
    hasMore: end < source.length,
  );
}

/// 「要处理」Tab 分页
class ActionItemsPaginatedNotifier extends AsyncNotifier<PaginatedItemsState> {
  List<Item> _source = [];

  @override
  Future<PaginatedItemsState> build() async {
    ref.watch(itemSearchQueryProvider);
    ref.watch(itemEventBusProvider);

    final items = await ref.watch(itemListSearchBaseProvider.future);
    _source = items.where((item) {
      final reason = computeItemListReason(item);
      return reason.isActionable && item.status == 0;
    }).toList();
    sortItemsByUrgency(_source);

    debugPrint(
      '[ActionItemsPaginated] INFO: 要处理共 ${_source.length} 件，首批 ${ItemListConstants.listPageSize}',
    );
    return _toPaginatedState(_source, ItemListConstants.listPageSize);
  }

  /// 滚动触底加载下一页
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextCount = math.min(
      _source.length,
      current.items.length + ItemListConstants.listPageSize,
    );
    debugPrint('[ActionItemsPaginated] INFO: 加载更多 -> $nextCount/${_source.length}');
    state = AsyncData(_toPaginatedState(_source, nextCount));
  }
}

final actionItemsPaginatedProvider =
    AsyncNotifierProvider<ActionItemsPaginatedNotifier, PaginatedItemsState>(
  ActionItemsPaginatedNotifier.new,
);

/// 「全部」Tab 分页
class AllItemsPaginatedNotifier extends AsyncNotifier<PaginatedItemsState> {
  List<Item> _source = [];

  @override
  Future<PaginatedItemsState> build() async {
    ref.watch(itemSearchQueryProvider);
    ref.watch(categoryFilterProvider);
    ref.watch(statusFilterProvider);
    ref.watch(expiringSoonFilterProvider);
    ref.watch(locationFilterProvider);
    ref.watch(itemSortProvider);
    ref.watch(itemEventBusProvider);

    _source = await ref.watch(filteredItemsProvider.future);
    debugPrint(
      '[AllItemsPaginated] INFO: 全部共 ${_source.length} 件，首批 ${ItemListConstants.listPageSize}',
    );
    return _toPaginatedState(_source, ItemListConstants.listPageSize);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextCount = math.min(
      _source.length,
      current.items.length + ItemListConstants.listPageSize,
    );
    debugPrint('[AllItemsPaginated] INFO: 加载更多 -> $nextCount/${_source.length}');
    state = AsyncData(_toPaginatedState(_source, nextCount));
  }
}

final allItemsPaginatedProvider =
    AsyncNotifierProvider<AllItemsPaginatedNotifier, PaginatedItemsState>(
  AllItemsPaginatedNotifier.new,
);
