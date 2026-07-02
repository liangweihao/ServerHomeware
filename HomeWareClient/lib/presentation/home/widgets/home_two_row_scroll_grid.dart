import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/home_constants.dart';
import '../../../core/models/home_section.dart';
import '../../items/widgets/item_card.dart';

/// 首页分区双排横向滚动网格 — 每列上下 2 张卡片，左右滑动查看更多
class HomeTwoRowScrollGrid extends StatelessWidget {
  const HomeTwoRowScrollGrid({
    super.key,
    required this.items,
  });

  final List<HomeSectionItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    debugPrint(
      '[HomeTwoRowScrollGrid] INFO: 渲染双排横向列表 ${items.length} 件',
    );

    return SizedBox(
      height: HomeConstants.twoRowListHeight,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: HomeConstants.horizontalPadding,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: HomeConstants.previewRowCount,
          mainAxisExtent: HomeConstants.cardWidth,
          crossAxisSpacing: HomeConstants.previewRowSpacing,
          mainAxisSpacing: HomeConstants.previewColumnSpacing,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ItemCard.feed(
            sectionItem: items[index],
            feedWidth: HomeConstants.cardWidth,
          );
        },
      ),
    );
  }
}
