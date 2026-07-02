import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/family_contribution_provider.dart';
import '../../common/widgets/app_card.dart';

/// 成员操作类型饼图 — 本月入库/消耗/丢弃等分布
class MemberOperationTypeChart extends ConsumerWidget {
  const MemberOperationTypeChart({
    super.key,
    required this.operatorName,
  });

  final String operatorName;

  /// 饼图色板（info/primary 为运行时 getter，不可用于 const）
  static final _colors = [
    AppColors.success,
    AppColors.info,
    AppColors.danger,
    AppColors.warning,
    AppColors.primary,
    AppColors.textSecondary,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memberOperationTypeStatsProvider(operatorName));

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.isEmpty) return const SizedBox.shrink();

        final total = stats.fold<int>(0, (sum, s) => sum + s.count);
        if (total == 0) return const SizedBox.shrink();

        final sections = stats.asMap().entries.map((entry) {
          final i = entry.key;
          final stat = entry.value;
          return PieChartSectionData(
            value: stat.count.toDouble(),
            title: stat.count >= total * 0.08
                ? '${((stat.count / total) * 100).round()}%'
                : '',
            color: _colors[i % _colors.length],
            radius: 52,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          );
        }).toList();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '操作类型分布',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '本月共 $total 次操作',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 28,
                          startDegreeOffset: -90,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: stats.asMap().entries.map((entry) {
                          final i = entry.key;
                          final stat = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _colors[i % _colors.length],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${stat.label} ${stat.count}',
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
