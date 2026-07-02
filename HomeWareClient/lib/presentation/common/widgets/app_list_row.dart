import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';

/// 设置/功能列表行 — 工具风 Icon + 标题 / 卡通 emoji 回退
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    this.icon,
    this.leadingEmoji,
    required this.title,
    this.subtitle,
    this.trailing,
    this.badgeCount,
    this.onTap,
    this.showChevron = true,
    this.iconColor,
  });

  final IconData? icon;
  final String? leadingEmoji;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final int? badgeCount;
  final VoidCallback? onTap;
  final bool showChevron;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildLeading(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badgeCount != null && badgeCount! > 0) ...[
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount! > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textHint,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (AppColors.isUtilityStyle && icon != null) {
      final accent = iconColor ?? AppColors.textSecondary;
      final (wellBg, wellFg) = AppColors.iconWellFor(accent);
      return Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: wellBg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          icon,
          size: 20,
          color: wellFg,
        ),
      );
    }

    if (leadingEmoji != null) {
      return Text(leadingEmoji!, style: const TextStyle(fontSize: 22));
    }

    if (icon != null) {
      return Icon(icon, size: 22, color: iconColor ?? AppColors.textSecondary);
    }

    return const SizedBox.shrink();
  }
}

/// 列表组内分割线 — 与 AppListRow leading 对齐
class AppListDivider extends StatelessWidget {
  const AppListDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Divider(height: 1, color: AppColors.homeDivider),
    );
  }
}
