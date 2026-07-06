import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/candy_icon.dart';
import '../../core/icons/candy_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/alert_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/family_provider.dart';
import '../../core/providers/home_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_list_row.dart';
import '../common/widgets/app_section_header.dart';
import '../common/widgets/warm_scaffold.dart';
import 'widgets/export_data_dialog.dart';
import 'widgets/profile_fade_slide_in.dart';
import 'widgets/profile_health_ring.dart';
import 'widgets/profile_identity_header.dart';
import 'widgets/profile_inventory_health.dart';
import 'widgets/profile_overview_strip.dart';
import '../../core/providers/profile_health_history_provider.dart';
import 'widgets/profile_health_trend_card.dart';
import 'widgets/profile_quick_action_grid.dart';
import 'widgets/profile_quick_actions_config.dart';

/// 个人中心 Tab — Bento 布局 + 健康度 + 动效
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider.notifier).currentUser;
    final unreadAsync = ref.watch(unreadAlertCountProvider);
    final unreadCount = unreadAsync.value ?? 0;
    final statsAsync = ref.watch(homeStatsProvider);
    final familyAsync = ref.watch(currentFamilyProvider);

    final stats = statsAsync.valueOrNull;
    final health = ProfileInventoryHealth.fromStats(stats);
    final pendingCount = stats == null
        ? 0
        : stats.expiredCount + stats.expiringCount + stats.lowStockCount;

    final familyName = familyAsync.valueOrNull?['name']?.toString();
    final skin = ref.watch(spaceSkinProvider);

    return WarmScaffold(
      title: '我的',
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          debugPrint('[ProfilePage] INFO: 下拉刷新');
          ref.invalidate(homeStatsProvider);
          ref.invalidate(currentFamilyProvider);
          ref.invalidate(unreadAlertCountProvider);
          ref.invalidate(profileHealthHistoryProvider);
          await Future.wait([
            ref.read(homeStatsProvider.future),
            ref.read(currentFamilyProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ProfileFadeSlideIn(
              child: ProfileIdentityHeader(
                nickname: user?.nickname ?? '用户',
                phone: user?.phone ?? '',
                familyName: familyName,
                roleLabel: _roleLabel(user?.familyRole),
                health: health,
                onHealthTap: () => context.push('/alerts'),
                onEdit: () => context.push('/profile/edit'),
              ),
            ),
            if (health.hasIssues) ...[
              const SizedBox(height: 12),
              ProfileFadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: ProfileHealthBanner(
                  health: health,
                  onTap: () => context.push('/alerts'),
                ),
              ),
            ],
            const SizedBox(height: 14),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 80),
              child: const ProfileHealthTrendCard(),
            ),
            const SizedBox(height: 14),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 100),
              child: ProfileOverviewStrip(
                tiles: [
                  ProfileOverviewTile(
                    label: '待处理',
                    value: '$pendingCount',
                    icon: CandyIcons.notificationsActive,
                    accentColor:
                        pendingCount > 0 ? AppColors.danger : AppColors.success,
                    urgent: pendingCount > 0,
                    onTap: () => context.push('/alerts'),
                  ),
                  ProfileOverviewTile(
                    label: skin.shoppingListLabel,
                    value: '${stats?.shoppingCount ?? 0}',
                    icon: CandyIcons.shoppingCart,
                    accentColor: AppColors.accentAmber,
                    onTap: () => context.push('/shopping'),
                  ),
                  ProfileOverviewTile(
                    label: '本月支出',
                    value: stats == null
                        ? '—'
                        : '¥${stats.monthlyExpense.toStringAsFixed(0)}',
                    icon: CandyIcons.wallet,
                    accentColor: AppColors.accentSky,
                    onTap: () => context.push('/statistics'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: const AppSectionHeader(title: '常用功能'),
            ),
            const SizedBox(height: 10),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 160),
              child: ProfileQuickActionGrid(
                actions: buildProfileQuickActions(
                  context,
                  skin: skin,
                  unreadCount: unreadCount,
                  pendingCount: pendingCount,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: const AppSectionHeader(title: '管理与偏好'),
            ),
            const SizedBox(height: 10),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    AppListRow(
                      icon: CandyIcons.place,
                      accent: AppColors.accentTeal,
                      title: '空间管理',
                      onTap: () => context.push('/locations'),
                    ),
                    const AppListDivider(),
                    AppListRow(
                      icon: CandyIcons.label,
                      accent: AppColors.accentViolet,
                      title: '分类管理',
                      onTap: () => context.push('/profile/categories'),
                    ),
                    const AppListDivider(),
                    AppListRow(
                      icon: CandyIcons.people,
                      accent: AppColors.accentSky,
                      title: '家庭成员',
                      onTap: () => context.push('/profile/family'),
                    ),
                    const AppListDivider(),
                    AppListRow(
                      icon: CandyIcons.notificationsActive,
                      accent: AppColors.accentRose,
                      title: '提醒设置',
                      onTap: () => context.push('/profile/notification-settings'),
                    ),
                    const AppListDivider(),
                    AppListRow(
                      icon: CandyIcons.palette,
                      accent: AppColors.accentAmber,
                      title: '主题样式',
                      onTap: () => context.push('/profile/theme-settings'),
                    ),
                    const AppListDivider(),
                    AppListRow(
                      icon: CandyIcons.upload,
                      accent: AppColors.accentSky,
                      title: '数据导出',
                      onTap: () => ExportDataDialog.show(context, ref),
                    ),
                    const AppListDivider(),
                    AppListRow(
                      icon: CandyIcons.info,
                      accent: AppColors.gray500,
                      title: '关于 HomeStock',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/profile/panel'),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '查看完整个人中心',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                  CandyIcon(
                    CandyIcons.chevronRight,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _roleLabel(String? role) {
    switch (role) {
      case 'admin':
        return '管理员';
      case 'owner':
        return '户主';
      case 'member':
        return '成员';
      default:
        return null;
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 HomeStock'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'HomeStock 是一款家庭物品管理应用，帮助你管理家庭物品、追踪保质期、预测消耗。',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
