import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import 'cartoon_chip.dart';

/// 分段筛选 Chip — 工具风描边 / 卡通 CartoonChip
class AppSegmentChip extends StatelessWidget {
  const AppSegmentChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    if (!AppColors.isUtilityStyle) {
      return CartoonChip(
        label: label,
        emoji: emoji,
        selected: selected,
        onTap: onTap,
      );
    }

    final selectedBg = selected
        ? (AppColors.isVividCleanStyle
            ? AppColors.white
            : AppColors.chipSelectedBackground)
        : AppColors.white;
    final selectedBorder = selected ? AppColors.primary : AppColors.homeDivider;
    final selectedText = selected
        ? (AppColors.isVividCleanStyle
            ? AppColors.primaryDark
            : AppColors.primaryDark)
        : AppColors.textSecondary;

    return Material(
      color: selectedBg,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: selectedBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selectedText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
