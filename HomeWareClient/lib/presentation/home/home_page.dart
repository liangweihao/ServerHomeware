import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/home_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/family_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/auth_service.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/shimmer_loading.dart';
import 'widgets/stat_card.dart';
import 'widgets/space_card.dart';
import 'widgets/activity_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 注册到 RouteObserver，监听页面可见性变化
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// 当其他页面 pop 后本页面重新可见时触发，刷新首页数据
  @override
  void didPopNext() {
    debugPrint('[HomePage] 页面恢复可见，刷新首页数据');
    ref.invalidate(currentFamilyProvider);
    ref.invalidate(homeStatsProvider);
    ref.invalidate(spacesProvider);
    ref.invalidate(recentActivitiesProvider);
  }

  @override
  Widget build(BuildContext context) {
    // 监听 GoRouter 路由变化，确保 location 变化时触发重建
    final _ = GoRouterState.of(context).uri;
    final currentFamilyAsync = ref.watch(currentFamilyProvider);

    return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentFamilyProvider);
              ref.invalidate(homeStatsProvider);
              ref.invalidate(spacesProvider);
              ref.invalidate(recentActivitiesProvider);
            },
            child: CustomScrollView(
              slivers: [
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
                        child: _buildFamilyTitle(context, currentFamilyAsync),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => context.push('/search'),
                      icon: const Icon(Icons.search),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('暂无新通知')),
                              );
                            },
                            icon: const Icon(Icons.notifications),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildAvatarButton(context, ref),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildStatsGrid(context, ref),
                      ),
                      const SizedBox(height: 24),
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
                      _buildSpacesList(context, ref),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
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
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {},
                              child: const Text('查看全部 →'),
                            ),
                          ],
                        ),
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

  /// 首页 AppBar 标题：展示当前选中家庭名称
  Widget _buildFamilyTitle(
    BuildContext context,
    AsyncValue<Map<String, dynamic>?> currentFamilyAsync,
  ) {
    final titleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
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
          childAspectRatio: 1.38,
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
          childAspectRatio: 1.38,
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
          return const SizedBox(
            height: 120,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text('暂无空间'),
              ),
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
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox(
        height: 120,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text('加载失败'),
          ),
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