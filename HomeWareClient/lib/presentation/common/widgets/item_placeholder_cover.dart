import 'package:flutter/material.dart';

import '../../../core/utils/item_placeholder_helper.dart';

/// 无图物品封面 — 分类 emoji + 暖色渐变 + 名称首字角标
class ItemPlaceholderCover extends StatelessWidget {
  const ItemPlaceholderCover({
    super.key,
    required this.itemName,
    required this.width,
    required this.height,
    this.categoryIcon,
    this.categoryColorHex,
    this.itemId,
    this.borderRadius,
  });

  final String itemName;
  final double width;
  final double height;
  final String? categoryIcon;
  final String? categoryColorHex;
  final int? itemId;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final accent = ItemPlaceholderHelper.resolveAccentColor(
      categoryColorHex: categoryColorHex,
      itemId: itemId ?? itemName.hashCode,
    );
    final emoji = ItemPlaceholderHelper.resolveEmoji(
      categoryIcon: categoryIcon,
      itemName: itemName,
    );
    final initial = ItemPlaceholderHelper.nameInitial(itemName);
    final radius = borderRadius ?? BorderRadius.zero;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.32),
              const Color(0xFFF5F0E8),
              Colors.white.withValues(alpha: 0.92),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: height * 0.36, height: 1),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
