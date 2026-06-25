import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_decorations.dart';

/// 物品列表分组标题 — 空间 / 分类区块
class ItemListSectionHeader extends StatelessWidget {
  const ItemListSectionHeader({
    super.key,
    required this.title,
    required this.emoji,
    required this.count,
  });

  final String title;
  final String emoji;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: CartoonDecorations.stickerCard(
              fillColor: AppColors.primaryLighter,
              borderColor: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              shadowLevel: CartoonShadowLevel.none,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count 件',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
