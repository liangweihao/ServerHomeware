import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/profile_health_history_provider.dart';
import '../../../core/services/profile_health_export_service.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_section_header.dart';

/// 健康分 7 日趋势折线图（支持 CSV 导出）
class ProfileHealthTrendCard extends ConsumerWidget {
  const ProfileHealthTrendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(profileHealthHistoryProvider);

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (history) {
        if (history.length < 2) {
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSectionHeader(title: '健康分趋势'),
                const SizedBox(height: 8),
                Text(
                  '再使用几天后会显示近 7 日趋势',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final recent = history.length > 7
            ? history.sublist(history.length - 7)
            : history;
        final spots = recent
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.score.toDouble()))
            .toList();
        final minY = (recent.map((e) => e.score).reduce((a, b) => a < b ? a : b) - 8)
            .clamp(30, 95)
            .toDouble();
        final maxY = 100.0;

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: AppSectionHeader(title: '健康分趋势'),
                  ),
                  IconButton(
                    tooltip: '导出 CSV',
                    icon: Icon(Icons.ios_share_outlined, color: AppColors.primary),
                    onPressed: () => _exportHealth(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '近 ${recent.length} 天家庭库存健康度',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppColors.gray200,
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 20,
                          getTitlesWidget: (v, _) => Text(
                            '${v.toInt()}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= recent.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              DateFormat('M/d').format(recent[i].date),
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textHint,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                            radius: 3,
                            color: AppColors.primary,
                            strokeWidth: 1,
                            strokeColor: AppColors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportHealth(BuildContext context) async {
    final ok = await ProfileHealthExportService.exportAndShare();
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无健康分历史可导出')),
      );
    }
  }
}

/// 刷新健康分历史 Provider
void invalidateProfileHealthHistory(WidgetRef ref) {
  ref.invalidate(profileHealthHistoryProvider);
}
