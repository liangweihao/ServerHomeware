import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../providers/family_contribution_provider.dart';
import '../../common/widgets/app_card.dart';

/// 成员本月分类操作分布
class MemberCategoryBreakdown extends ConsumerWidget {
  const MemberCategoryBreakdown({
    super.key,
    required this.operatorName,
  });

  final String operatorName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memberCategoryStatsProvider(operatorName));

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.isEmpty) return const SizedBox.shrink();

        final maxTotal = stats.map((s) => s.total).reduce((a, b) => a > b ? a : b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分类分布',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: List.generate(stats.length, (i) {
                  final s = stats[i];
                  final ratio = maxTotal > 0 ? s.total / maxTotal : 0.0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < stats.length - 1 ? 12 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.categoryName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '录${s.recordCount} 耗${s.consumeCount}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: AppColors.gray200,
                            color: AppColors.primary.withValues(
                              alpha: 0.55 + ratio * 0.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}
