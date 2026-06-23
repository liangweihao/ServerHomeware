import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/alert_provider.dart';
import '../../core/providers/home_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/family_provider.dart';
import '../../core/services/auth_service.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/shimmer_loading.dart';
import 'widgets/stat_card.dart';
import 'widgets/space_card.dart';
import 'widgets/activity_item.dart';
import 'widgets/today_alert_banner.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFamilyAsync = ref.watch(currentFamilyProvider);
    final statsAsync = ref.watch(homeStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentFamilyProvider);
            ref.invalidate(homeStatsProvider);
            ref.invalidate(spacesProvider);
            ref.invalidate(recentActivitiesProvider);
            invalidateAlertProviders(ref);
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                centerTitle: false,
                title: GestureDetector(
                  onTap: () {
                    debugPrint('[HomePage] INFO: 打开用户面板');
                    context.push('/profile/panel');
                  },
                  child: _buildFamilyTitle(context, currentFamilyAsync),
                ),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.search),
                    tooltip: '搜索',
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final unreadAsync = ref.watch(unreadAlertCountProvider);
                      final unreadCount = unreadAsync.value ?? 0;
                      return Badge(
                        label: unreadCount > 0 ? Text('$unreadCount') : null,
                        isLabelVisible: unreadCount > 0,
                        child: IconButton(
                          onPressed: () {
                            debugPrint('[HomePage] INFO: 打开通知中心');
                            context.push('/notifications');
                          },
                          icon: const Icon(Icons.notifications_outlined),
                          tooltip: '通知中心',
                        ),
                      );
                    },
                  ),
                  _buildAvatarButton(context, ref),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    statsAsync.when(
                      data: (stats) => TodayAlertBanner(
                        stats: stats,
                        onTap: () {
                          debugPrint('[HomePage] INFO: 今日待办条 -> 通知中心');
                          context.push('/notifications');
                        },
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    _buildSectionHeader(context, title: '需要关注'),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildStatsGrid(context, ref, statsAsync),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      context,
                      title: '快捷查看',
                      actionLabel: '全部空间',
                      onAction: () => context.push('/locations'),
                    ),
                    const SizedBox(height: 12),
                    _buildSpacesList(context, ref),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      context,
                      title: '最近动态',
                      actionLabel: '查看全部',
                      onAction: () {
                        debugPrint('[HomePage] INFO: 查看全部动态（待实现列表页）');
                      },
                    ),
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('$actionLabel →'),
            ),
        ],
      ),
    );
  }

  /// 首页 AppBar 标题：展示当前选中家庭名称
  Widget _buildFamilyTitle(
    BuildContext context,
    AsyncValue<Map<String, dynamic>?> currentFamilyAsync,
  ) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        );

    return currentFamilyAsync.when(
      data: (family) {
        final name = family?['name']?.toString();
        if (name == null || name.isEmpty) {
          debugPrint('[HomePage] WARN: 当前无家庭，显示占位标题');
        }
        return Text(
          (name != null && name.isNotEmpty) ? name : '未加入家庭',
          style: titleStyle,
          overflow: TextOverflow.ellipsis,
        );
      },
      loading: () => Text(
        '…',
        style: titleStyle,
        overflow: TextOverflow.ellipsis,
      ),
      error: (error, _) {
        debugPrint('[HomePage] ERROR: 加载家庭名称失败 - $error');
        return Text(
          '未加入家庭',
          style: titleStyle,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<HomeStats> statsAsync,
  ) {
    return statsAsync.when(
      data: (stats) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.38,
          children: [
            StatCard(
              icon: Icons.schedule_outlined,
              accentColor: AppColors.danger,
              title: '即将过期',
              count: '${stats.expiringCount}件',
              subtitle: stats.latestExpiringItem != null
                  ? '最近：${stats.latestExpiringItem}'
                  : null,
              onTap: () => context.push('/alerts'),
            ),
            StatCard(
              icon: Icons.inventory_2_outlined,
              accentColor: AppColors.warning,
              title: '库存不足',
              count: '${stats.lowStockCount}件',
              subtitle: stats.latestLowStockItem != null
                  ? '最近：${stats.latestLowStockItem}'
                  : null,
              onTap: () => context.push('/alerts'),
            ),
            StatCard(
              icon: Icons.shopping_cart_outlined,
              accentColor: AppColors.primary,
              title: '待购清单',
              count: '${stats.shoppingCount}项',
              onTap: () => context.push('/shopping'),
            ),
            StatCard(
              icon: Icons.payments_outlined,
              accentColor: AppColors.success,
              title: '本月消费',
              count: '¥${stats.monthlyExpense.toStringAsFixed(2)}',
              subtitle: () {
                final change = stats.monthlyExpenseChange;
                if (change == null || change == 0) return null;
                final prefix = change.isNegative ? '↓' : '↑';
                return '比上月 $prefix${change.abs().toStringAsFixed(0)}%';
              }(),
              onTap: () => context.push('/statistics'),
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
        childAspectRatio: 1.38,
        children: const [
          ShimmerStatCard(),
          ShimmerStatCard(),
          ShimmerStatCard(),
          ShimmerStatCard(),
        ],
      ),
      error: (error, stack) => AppEmptyState(
        icon: '❌',
        title: '加载失败',
        subtitle: error.toString(),
        actionLabel: '重试',
        onAction: () => ref.invalidate(homeStatsProvider),
      ),
    );
  }

  Widget _buildSpacesList(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(spacesProvider);

    return spacesAsync.when(
      data: (spaces) {
        if (spaces.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text('暂无空间')),
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
      loading: () => const SizedBox(
        height: 120,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => const SizedBox(
        height: 120,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(child: Text('加载失败')),
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: activities
                .map(
                  (activity) => ActivityItem(
                    activity: activity,
                    onTap: activity.itemId != null
                        ? () => context.push('/items/${activity.itemId}')
                        : null,
                  ),
                )
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

  Widget _buildAvatarButton(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider.notifier).currentUser;
    final avatarIndex = AuthService.getAvatarColorIndex(user?.phone ?? '');
    final colors = AuthService.getAvatarColors(avatarIndex);
    String displayChar = '?';
    if (user?.nickname != null && user!.nickname!.isNotEmpty) {
      displayChar = user.nickname![0].toUpperCase();
    } else if (user?.phone != null) {
      displayChar = user!.phone!.substring(user.phone!.length - 4);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => context.push('/profile/panel'),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(colors[0]), Color(colors[1])],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              displayChar,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
