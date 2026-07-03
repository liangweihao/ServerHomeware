import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/models/home_section.dart';
import '../../core/providers/home_provider.dart';
import 'providers/home_sections_provider.dart';
import 'widgets/home_item_section.dart';
import 'widgets/home_section_shimmer.dart';
import 'widgets/home_space_section.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/today_summary_banner.dart';

/// 单页首页 — 顶栏固定，其余（今日待办 + 分区 Feed + 按空间）同一列表滚动
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(homeSectionsProvider);
    final statsAsync = ref.watch(homeStatsProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const HomeTopBar(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    debugPrint('[HomePage] INFO: 下拉刷新首页');
                    ref.invalidate(homeSectionsProvider);
                    ref.invalidate(homeStatsProvider);
                    ref.read(itemEventBusProvider.notifier).notifyUpdated();
                    await Future.wait([
                      ref.read(homeSectionsProvider.future),
                      ref.read(homeStatsProvider.future),
                    ]);
                  },
                  child: sectionsAsync.when(
                    data: (sections) => _buildScrollBody(
                      context,
                      sections: sections,
                      statsAsync: statsAsync,
                    ),
                    loading: () => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        HomeSectionShimmer(),
                        HomeSectionShimmer(),
                      ],
                    ),
                    error: (error, _) {
                      debugPrint('[HomePage] ERROR: 加载失败 $error');
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Text(
                                  '加载失败',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$error',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () =>
                                      ref.invalidate(homeSectionsProvider),
                                  child: const Text('重试'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollBody(
    BuildContext context, {
    required List<HomeSectionData> sections,
    required AsyncValue<HomeStats> statsAsync,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        statsAsync.when(
          data: (stats) {
            final total = stats.expiredCount +
                stats.expiringCount +
                stats.lowStockCount;
            if (total <= 0) return const SizedBox.shrink();
            return TodaySummaryBanner(
              stats: stats,
              onOpenAlerts: () {
                debugPrint('[HomePage] INFO: 跳转提醒中心');
                context.push('/alerts');
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        ...sections.map(
          (section) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: HomeItemSection(section: section),
          ),
        ),
        const HomeSpaceSection(),
      ],
    );
  }
}
