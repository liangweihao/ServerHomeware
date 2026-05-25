import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/home_provider.dart';
import '../../core/providers/shopping_provider.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/shimmer_loading.dart';
import 'widgets/stat_card.dart';
import 'widgets/space_card.dart';
import 'widgets/activity_item.dart';
import 'widgets/home_shimmer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeStatsProvider);
            ref.invalidate(spacesProvider);
            ref.invalidate(recentActivitiesProvider);
          },
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                title: Row(
                  children: [
                    const Text(
                      '🏠',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '我的家',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // 搜索按钮
                  IconButton(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.search),
                  ),
                  // 头像
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // 内容区域
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // 需要关注区域
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('⚠️ ', style: TextStyle(fontSize: 18)),
                          Text(
                            '需要关注',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 统计卡片网格
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildStatsGrid(context, ref),
                    ),

                    const SizedBox(height: 24),

                    // 快捷空间入口
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('📍 ', style: TextStyle(fontSize: 18)),
                          Text(
                            '快捷查看',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 空间卡片列表
                    _buildSpacesList(context, ref),

                    const SizedBox(height: 24),

                    // 最近动态
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text('📅 ', style: TextStyle(fontSize: 18)),
                              Flexible(
                                child: Text(
                                  '最近动态',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              // TODO: 跳转到全部动态页面
                            },
                            child: const Text('查看全部 →'),
                          ),
                        ],
                      ),
                    ),

                    // 动态列表
                    _buildActivitiesList(context, ref),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              emoji: '🔴',
              title: '即将过期',
              count: '${stats.expiringCount}件',
              subtitle: stats.latestExpiringItem != null
                  ? '最近：${stats.latestExpiringItem}'
                  : null,
              onTap: () => context.push('/alerts'),
              backgroundColor: AppColors.dangerLight,
            ),
            StatCard(
              emoji: '📦',
              title: '库存不足',
              count: '${stats.lowStockCount}件',
              subtitle: stats.latestLowStockItem != null
                  ? '最近：${stats.latestLowStockItem}'
                  : null,
              onTap: () => context.push('/alerts'),
              backgroundColor: AppColors.warningLight,
            ),
            StatCard(
              emoji: '🛒',
              title: '待购清单',
              count: '${stats.shoppingCount}项',
              onTap: () => context.push('/shopping'),
              backgroundColor: AppColors.infoLight,
            ),
            StatCard(
              emoji: '📊',
              title: '本月消费',
              count: '¥${stats.monthlyExpense.toStringAsFixed(2)}',
              subtitle: () {
                final change = stats.monthlyExpenseChange;
                if (change == null || change == 0) return null;
                final prefix = change.isNegative ? '↓' : '↑';
                return '比上月 $prefix${change.abs().toStringAsFixed(0)}%';
              }(),
              onTap: () => context.push('/statistics'),
              backgroundColor: AppColors.successLight,
            ),
          ],
        );
      },
      loading: () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: const [
          ShimmerStatCard(),
          ShimmerStatCard(),
          ShimmerStatCard(),
          ShimmerStatCard(),
        ],
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: AppEmptyState(
          icon: '❌',
          title: '加载失败',
          subtitle: error.toString(),
          actionLabel: '重试',
          onAction: () => ref.invalidate(homeStatsProvider),
        ),
      ),
    );
  }

  Widget _buildSpacesList(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(spacesProvider);

    return spacesAsync.when(
      data: (spaces) {
        if (spaces.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppEmptyState(
              icon: '🏠',
              title: '还没有空间',
              subtitle: '去添加你的第一个空间吧',
              actionLabel: '添加空间',
              onAction: () => context.push('/locations'),
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: spaces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final space = spaces[index];
              return SpaceCard(
                location: space.location,
                itemCount: space.itemCount,
                onTap: () => context.push('/locations/${space.location.id}'),
              );
            },
          ),
        );
      },
      loading: () => SizedBox(
        height: 120,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => const ShimmerSpaceCard(),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppEmptyState(
          icon: '❌',
          title: '加载失败',
          subtitle: error.toString(),
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppEmptyState(
              icon: '📝',
              title: '暂无动态',
              subtitle: '开始添加物品记录你的生活',
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: activities
                .map((activity) => ActivityItem(
                      activity: activity,
                      onTap: activity.itemId != null
                          ? () => context.push('/items/${activity.itemId}')
                          : null,
                    ))
                .toList(),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppEmptyState(
          icon: '❌',
          title: '加载失败',
          subtitle: error.toString(),
        ),
      ),
    );
  }
}
