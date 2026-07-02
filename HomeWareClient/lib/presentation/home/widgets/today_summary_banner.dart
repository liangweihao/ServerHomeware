import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/home_provider.dart';

/// 今日待办摘要 — 强化回访吸引力（书旗 weak summary + 点评快捷入口）
class TodaySummaryBanner extends StatelessWidget {
  const TodaySummaryBanner({
    super.key,
    required this.stats,
    required this.onOpenAlerts,
  });

  final HomeStats stats;
  final VoidCallback onOpenAlerts;

  int get _totalIssues =>
      stats.expiredCount + stats.expiringCount + stats.lowStockCount;

  String _headline() {
    if (_totalIssues <= 0) return '今天暂无待处理';
    return '今天要处理 $_totalIssues 件事';
  }

  String _detailLine() {
    final parts = <String>[];
    if (stats.expiredCount > 0) {
      parts.add('${stats.expiredCount} 件已过期');
    }
    if (stats.expiringCount > 0) {
      parts.add('${stats.expiringCount} 件临期');
    }
    if (stats.lowStockCount > 0) {
      parts.add('${stats.lowStockCount} 件需补货');
    }
    return parts.join(' · ');
  }

  String? _exampleLine() {
    final examples = <String>[];
    if (stats.latestExpiredItem != null) {
      examples.add(stats.latestExpiredItem!);
    }
    if (stats.latestExpiringItem != null &&
        stats.latestExpiringItem != stats.latestExpiredItem) {
      examples.add(stats.latestExpiringItem!);
    }
    if (stats.latestLowStockItem != null &&
        !examples.contains(stats.latestLowStockItem)) {
      examples.add(stats.latestLowStockItem!);
    }
    if (examples.isEmpty) return null;
    return '例如：${examples.take(2).join('、')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_totalIssues <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Material(
        color: AppColors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onOpenAlerts,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _headline(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textHint),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _detailLine(),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                if (_exampleLine() != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _exampleLine()!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (stats.expiredCount > 0)
                      _QuickChip(
                        label: '已过期',
                        onTap: () {
                          debugPrint('[TodaySummary] INFO: 跳转提醒中心-过期');
                          context.push('/alerts?tab=expiry');
                        },
                      ),
                    if (stats.expiringCount > 0)
                      _QuickChip(
                        label: '临期',
                        onTap: () {
                          debugPrint('[TodaySummary] INFO: 跳转提醒中心-临期');
                          context.push('/alerts?tab=expiry');
                        },
                      ),
                    if (stats.lowStockCount > 0)
                      _QuickChip(
                        label: '低库存',
                        onTap: () {
                          debugPrint('[TodaySummary] INFO: 跳转提醒中心-库存');
                          context.push('/alerts?tab=stock');
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppColors.primaryLighter,
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
      onPressed: onTap,
    );
  }
}
