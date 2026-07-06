import 'dart:math' as math;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/item_list_constants.dart';
import '../../../data/database/app_database.dart';
import 'item_grid_masonry.dart';

/// 分组网格 — 组内首批展示 + 「加载更多」
class PaginatedGridSection extends StatefulWidget {
  const PaginatedGridSection({
    super.key,
    required this.groupKey,
    required this.allItems,
    required this.itemBuilder,
    this.pageSize = ItemListConstants.gridPageSize,
  });

  /// 分组唯一键（空间名 / 分类 id）
  final String groupKey;
  final List<Item> allItems;
  final Widget Function(Item item, int index) itemBuilder;
  final int pageSize;

  @override
  State<PaginatedGridSection> createState() => _PaginatedGridSectionState();
}

class _PaginatedGridSectionState extends State<PaginatedGridSection> {
  late int _visibleCount;

  @override
  void initState() {
    super.initState();
    _visibleCount = math.min(widget.pageSize, widget.allItems.length);
  }

  @override
  void didUpdateWidget(covariant PaginatedGridSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allItems != widget.allItems ||
        oldWidget.groupKey != widget.groupKey) {
      _visibleCount = math.min(widget.pageSize, widget.allItems.length);
    }
  }

  bool get _hasMore => _visibleCount < widget.allItems.length;

  void _loadMore() {
    if (!_hasMore) return;
    final next = math.min(
      _visibleCount + widget.pageSize,
      widget.allItems.length,
    );
    debugPrint(
      '[PaginatedGridSection] INFO: ${widget.groupKey} 加载更多 $next/${widget.allItems.length}',
    );
    setState(() => _visibleCount = next);
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.allItems.take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ItemGridMasonry(
          items: visible,
          itemBuilder: widget.itemBuilder,
        ),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Center(
              child: TextButton.icon(
                onPressed: _loadMore,
                icon: const CandyIcon(Icons.expand_more, size: 18),
                label: Text(
                  '加载更多 ($_visibleCount/${widget.allItems.length})',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
