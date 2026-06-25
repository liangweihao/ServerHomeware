import 'package:flutter/material.dart';
import '../../../data/database/app_database.dart';
import 'item_card.dart';

/// 双列瀑布流网格 — 卡片高度随内容（图片比例）自适应
class ItemGridMasonry extends StatelessWidget {
  const ItemGridMasonry({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.spacing = 12,
  });

  final List<Item> items;
  final Widget Function(Item item, int index) itemBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final leftColumn = <Widget>[];
    final rightColumn = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final card = Padding(
        padding: EdgeInsets.only(bottom: spacing),
        child: itemBuilder(items[i], i),
      );
      if (i.isEven) {
        leftColumn.add(card);
      } else {
        rightColumn.add(card);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: leftColumn)),
        SizedBox(width: spacing),
        Expanded(child: Column(children: rightColumn)),
      ],
    );
  }
}
