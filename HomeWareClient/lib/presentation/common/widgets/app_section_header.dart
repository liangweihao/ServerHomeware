import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 区块标题 — 工具风纯文字 / 卡通可带 emoji
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.emoji,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final String title;
  final String? emoji;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final displayTitle = (AppColors.isUtilityStyle || emoji == null)
        ? title
        : '$emoji $title';

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.isUtilityStyle
                    ? AppColors.textPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}
