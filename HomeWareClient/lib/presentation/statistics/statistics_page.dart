import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/config/space_skin_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/shop_daily_sales_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../../core/providers/statistics_provider.dart';
import '../../core/shop/shop_daily_sales_models.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/app_section_header.dart';
import '../common/widgets/app_segment_chip.dart';
import '../common/widgets/warm_scaffold.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRange = ref.watch(timeRangeProvider);

    return WarmScaffold(
      title: '数据统计',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(consumptionStatsProvider);
          ref.invalidate(categoryStatsProvider);
          ref.invalidate(wasteStatsProvider);
          ref.invalidate(consumptionRankingProvider);
          ref.invalidate(shopDailySalesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildShopDailySalesSection(context, ref),
            // 时间维度切换
            _buildTimeRangeSelector(context, ref, timeRange),
            const SizedBox(height: 24),

            // 消费概览
            _buildConsumptionOverview(context, ref),
            const SizedBox(height: 24),

            // 分类占比
            _buildCategorySection(context, ref),
            const SizedBox(height: 24),

            // 浪费统计
            _buildWasteSection(context, ref),
            const SizedBox(height: 24),

            // 消耗排行
            _buildRankingSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context, WidgetRef ref, TimeRange selected) {
    return Row(
      children: [
        for (final range in TimeRange.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppSegmentChip(
                label: range == TimeRange.week
                    ? '本周'
                    : range == TimeRange.month
                        ? '本月'
                        : '本年',
                emoji: range == TimeRange.week
                    ? '📅'
                    : range == TimeRange.month
                        ? '🗓️'
                        : '📆',
                selected: selected == range,
                onTap: () {
                  ref.read(timeRangeProvider.notifier).state = range;
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConsumptionOverview(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(consumptionStatsProvider);

    return statsAsync.when(
      data: (stats) {
        // 检查是否有数据
        if (stats.totalExpense == 0 && stats.monthlyTrend.isEmpty) {
          return AppSectionCard(
            colorIndex: 0,
            child: const AppEmptyState(
              icon: '📊',
              title: '数据不足',
              subtitle: '添加更多物品后可查看统计',
            ),
          );
        }
        return AppSectionCard(
          colorIndex: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(title: '消费概览', emoji: '💰'),
              const SizedBox(height: 16),
              Text(
                '¥${stats.totalExpense.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              if (stats.expenseChange != null) ...[
                const SizedBox(height: 8),
                Text(
                  '较上月 ${stats.expenseChange! > 0 ? '↑' : '↓'}${stats.expenseChange!.abs().toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: stats.expenseChange! > 0 ? AppColors.danger : AppColors.success,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: _buildTrendChart(stats.monthlyTrend),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => AppEmptyState(
        icon: '❌',
        title: '加载失败',
        subtitle: error.toString(),
      ),
    );
  }

  Widget _buildTrendChart(List<MonthlyExpense> data) {
    if (data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.amount);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MM月').format(data[index].month),
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
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
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryStatsProvider);

    return AppSectionCard(
      colorIndex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: '分类占比', emoji: '📊'),
          const SizedBox(height: 16),
          categoryAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('暂无数据')),
                );
              }

              return Column(
                children: categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '¥${cat.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${cat.percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: cat.percentage / 100,
                          backgroundColor: AppColors.divider,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(int.parse(cat.color.replaceFirst('#', '0xFF'))),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteSection(BuildContext context, WidgetRef ref) {
    final wasteAsync = ref.watch(wasteStatsProvider);

    return AppSectionCard(
      colorIndex: 2,
      child: _buildWasteContent(context, ref, wasteAsync),
    );
  }

  Widget _buildWasteContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<WasteStats> wasteAsync,
  ) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: '浪费统计', emoji: '🗑️'),
          const SizedBox(height: 16),
          wasteAsync.when(
            data: (waste) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${waste.count}件',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '¥${waste.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.danger,
                            ),
                      ),
                    ],
                  ),
                  if (waste.items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...waste.items.take(3).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item.name),
                              Text(
                                '¥${item.price.toStringAsFixed(2)}',
                                style: const TextStyle(color: AppColors.danger),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 8),
                    Text(
                      '💡 建议：减少一次性购买量',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
    );
  }

  Widget _buildRankingSection(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(consumptionRankingProvider);

    return AppSectionCard(
      colorIndex: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(title: '消耗排行', emoji: '🏆'),
          const SizedBox(height: 16),
          rankingAsync.when(
            data: (ranking) {
              if (ranking.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('暂无数据')),
                );
              }

              return Column(
                children: ranking.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? const Color(0xFFFFD700)
                                : index == 1
                                    ? const Color(0xFFC0C0C0)
                                    : index == 2
                                        ? const Color(0xFFCD7F32)
                                        : AppColors.divider,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: index < 3 ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textHint,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '¥${item.amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }

  /// B+ 店铺近 7 日卖出统计（shop 专属）
  Widget _buildShopDailySalesSection(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(spaceSkinProvider);
    if (!skin.showSalePrice) return const SizedBox.shrink();

    final salesAsync = ref.watch(shopDailySalesProvider);
    return salesAsync.when(
      data: (summary) {
        if (summary.days.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: AppSectionCard(
            colorIndex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionHeader(
                  title: skin.dailySalesCardTitle,
                  emoji: '📈',
                ),
                const SizedBox(height: 12),
                Text(
                  skin.dailySalesHeadline(
                    sellTimes: summary.totalSellTimes,
                    totalRevenue: summary.totalRevenue,
                    revenueComplete: summary.revenueIsComplete,
                    totalGrossProfit: summary.totalGrossProfit,
                    costIsComplete: summary.costIsComplete,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                if (summary.hasSales) ...[
                  const SizedBox(height: 14),
                  _buildProfitKpiRow(context, skin, summary),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: summary.hasSales
                      ? _buildProfitBarChart(summary)
                      : _buildDailySalesBarChart(summary),
                ),
                if (summary.hasSales) ...[
                  const SizedBox(height: 8),
                  _buildChartLegend(context),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// 近7日营业额 / 成本 / 毛利 KPI
  Widget _buildProfitKpiRow(
    BuildContext context,
    SpaceSkinConfig skin,
    ShopDailySalesSummary summary,
  ) {
    return Row(
      children: [
        Expanded(
          child: _ProfitKpiTile(
            label: '营业额',
            value: skin.formatCurrency(summary.totalRevenue),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ProfitKpiTile(
            label: '成本',
            value: skin.formatCurrency(summary.totalCost),
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ProfitKpiTile(
            label: '毛利',
            value: skin.formatCurrency(summary.totalGrossProfit),
            color: summary.totalGrossProfit >= 0
                ? AppColors.success
                : AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppColors.primary, label: '营业额'),
        const SizedBox(width: 16),
        _LegendDot(color: AppColors.success, label: '毛利'),
      ],
    );
  }

  /// 双柱图 — 每日营业额 vs 毛利
  Widget _buildProfitBarChart(ShopDailySalesSummary summary) {
    final days = summary.days;
    if (days.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    var maxVal = 0.0;
    for (final d in days) {
      if (d.revenue > maxVal) maxVal = d.revenue;
      if (d.grossProfit > maxVal) maxVal = d.grossProfit;
    }
    final top = maxVal < 1 ? 1.0 : maxVal * 1.25;

    return BarChart(
      BarChartData(
        maxY: top,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: top / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.primaryLighter,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: top / 4,
              getTitlesWidget: (value, meta) {
                if (value <= 0) return const SizedBox.shrink();
                return Text(
                  value >= 1000
                      ? '${(value / 1000).toStringAsFixed(1)}k'
                      : value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                final label = DateFormat('E', 'zh_CN').format(days[i].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.replaceAll('星期', '周'),
                    style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: days[i].revenue,
                  color: AppColors.primary.withValues(alpha: 0.85),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
                BarChartRodData(
                  toY: days[i].grossProfit,
                  color: AppColors.success.withValues(alpha: 0.85),
                  width: 8,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDailySalesBarChart(ShopDailySalesSummary summary) {
    final days = summary.days;
    if (days.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final maxY = days.map((d) => d.sellTimes.toDouble()).reduce((a, b) => a > b ? a : b);
    final top = maxY < 1 ? 1.0 : maxY * 1.2;

    return BarChart(
      BarChartData(
        maxY: top,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                final label = DateFormat('E', 'zh_CN').format(days[i].date);
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.replaceAll('星期', '周'),
                    style: const TextStyle(fontSize: 10, color: AppColors.textHint),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i].sellTimes.toDouble(),
                  color: AppColors.primary,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProfitKpiTile extends StatelessWidget {
  const _ProfitKpiTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
      ],
    );
  }
}
