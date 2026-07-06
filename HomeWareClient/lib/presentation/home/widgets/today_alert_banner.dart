import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/home_provider.dart';

/// 今日待办摘要条 — 仅有即将过期或库存不足时显示
class TodayAlertBanner extends StatelessWidget {
  final HomeStats stats;
  final VoidCallback onTap;

  const TodayAlertBanner({
    super.key,
    required this.stats,
    required this.onTap,
  });

  String _summaryText() {
    final parts = <String>[];
    if (stats.expiringCount > 0) {
      parts.add('${stats.expiringCount} 件即将过期');
    }
    if (stats.lowStockCount > 0) {
      parts.add('${stats.lowStockCount} 件库存偏低');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    if (stats.expiringCount + stats.lowStockCount <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CandyIcon(
                  Icons.notifications_active_outlined,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _summaryText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                CandyIcon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
