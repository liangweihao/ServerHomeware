import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/space_skin_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/shop_daily_sales_provider.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/shop/shop_daily_sales_models.dart';

/// B+ 店铺近 7 日简易日销卡片 — 仅 shop 空间展示
class ShopDailySalesCard extends ConsumerWidget {
  const ShopDailySalesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(spaceSkinProvider);
    if (!skin.showSalePrice) return const SizedBox.shrink();

    final salesAsync = ref.watch(shopDailySalesProvider);
    return salesAsync.when(
      data: (summary) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: _ShopDailySalesBody(skin: skin, summary: summary),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) {
        debugPrint('[ShopDailySalesCard] ERROR: $e');
        return const SizedBox.shrink();
      },
    );
  }
}

class _ShopDailySalesBody extends StatelessWidget {
  const _ShopDailySalesBody({
    required this.skin,
    required this.summary,
  });

  final SpaceSkinConfig skin;
  final ShopDailySalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final weekdayFmt = DateFormat('E', 'zh_CN');

    return Material(
      color: AppColors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: () {
          debugPrint('[ShopDailySalesCard] INFO: 跳转数据统计');
          context.push('/statistics');
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📈', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    skin.dailySalesCardTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                skin.dailySalesHeadline(
                  sellTimes: summary.totalSellTimes,
                  totalRevenue: summary.totalRevenue,
                  revenueComplete: summary.revenueIsComplete,
                  totalGrossProfit: summary.totalGrossProfit,
                  costIsComplete: summary.costIsComplete,
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              if (summary.days.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 72,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final day in summary.days) ...[
                        Expanded(
                          child: _DayBar(
                            label: weekdayFmt.format(day.date),
                            sellTimes: day.sellTimes,
                            maxTimes: _maxSellTimes(summary.days),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _maxSellTimes(List<DailySalesDay> days) {
    var max = 0;
    for (final d in days) {
      if (d.sellTimes > max) max = d.sellTimes;
    }
    return max;
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.label,
    required this.sellTimes,
    required this.maxTimes,
  });

  final String label;
  final int sellTimes;
  final int maxTimes;

  @override
  Widget build(BuildContext context) {
    final ratio = maxTimes > 0 ? sellTimes / maxTimes : 0.0;
    final barHeight = 36.0 * ratio + (sellTimes > 0 ? 4 : 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (sellTimes > 0)
            Text(
              '$sellTimes',
              style: TextStyle(fontSize: 10, color: AppColors.textHint),
            ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: barHeight,
            decoration: BoxDecoration(
              color: sellTimes > 0
                  ? AppColors.primary.withValues(alpha: 0.85)
                  : AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.replaceAll('星期', '周'),
            style: TextStyle(fontSize: 10, color: AppColors.textHint),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
