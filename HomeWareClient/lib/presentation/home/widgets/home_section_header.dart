import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_constants.dart';
import '../../../core/models/home_section.dart';

/// 首页分区头部：图标 + 主副标题 + 查看全部（统一布局，避免文案长短不一）
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.config,
    required this.itemCount,
    required this.onViewAll,
  });

  final HomeSectionConfig config;
  final int itemCount;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final countLabel = itemCount > 0 ? ' · $itemCount 件' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HomeConstants.horizontalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SectionIcon(
            icon: config.icon,
            accentColor: config.accentColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${config.subtitle}$countLabel',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('查看全部', style: TextStyle(fontSize: 14)),
                SizedBox(width: 2),
                CandyIcon(Icons.chevron_right, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 分区图标容器 — 固定 36×36，保证各分区头部视觉一致
class _SectionIcon extends StatelessWidget {
  const _SectionIcon({
    required this.icon,
    required this.accentColor,
  });

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CandyIcon(icon, size: 20, color: accentColor),
    );
  }
}
