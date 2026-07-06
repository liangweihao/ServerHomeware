import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/icons/app_icon.dart';
import '../../core/icons/candy_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/contribution_stats.dart';
import '../../core/providers/alert_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/family_provider.dart';
import '../../core/providers/home_provider.dart';
import '../../core/providers/realtime_sync_status_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/contribution_service.dart';
import '../../core/services/family_service.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_list_row.dart';
import '../common/widgets/app_section_header.dart';
import '../common/widgets/warm_scaffold.dart';
import 'widgets/export_data_dialog.dart';
import 'widgets/family_contribution_section.dart';
import 'widgets/profile_contribution_card.dart';
import 'widgets/profile_family_card.dart';
import 'widgets/profile_fade_slide_in.dart';
import 'widgets/profile_health_ring.dart';
import 'widgets/profile_identity_header.dart';
import 'widgets/profile_inventory_health.dart';
import 'widgets/profile_overview_strip.dart';
import '../../core/auth/shop_role_guard.dart';
import '../../core/providers/family_role_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import 'widgets/profile_health_trend_card.dart';
import 'widgets/profile_quick_action_grid.dart';
import 'widgets/profile_quick_actions_config.dart';
import 'widgets/switch_family_bottom_sheet.dart';

/// 完整个人中心 — 从首页头像进入，含家庭/贡献/同步状态
class ProfilePanelPage extends ConsumerStatefulWidget {
  const ProfilePanelPage({super.key});

  @override
  ConsumerState<ProfilePanelPage> createState() => _ProfilePanelPageState();
}

class _ProfilePanelPageState extends ConsumerState<ProfilePanelPage> {
  bool _familyLoading = true;
  bool _contributionLoading = true;
  Map<String, dynamic>? _familyData;
  UserContributionStats? _contributionStats;
  String _inviteCode = '';
  bool _familyNetworkError = false;
  bool _contributionNetworkError = false;
  List<Map<String, dynamic>> _families = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefreshFamily = false}) async {
    setState(() {
      _familyLoading = true;
      _contributionLoading = true;
      _familyNetworkError = false;
      _contributionNetworkError = false;
    });

    final user = ref.read(authProvider.notifier).currentUser;
    final userId = user?.id;
    if (userId == null || userId.isEmpty) {
      setState(() {
        _familyData = null;
        _familyLoading = false;
        _contributionLoading = false;
      });
      return;
    }

    final cachedFamily = ref.read(currentFamilyProvider).valueOrNull;
    if (cachedFamily != null && !forceRefreshFamily) {
      setState(() {
        _familyData = cachedFamily;
        _inviteCode = cachedFamily['invite_code']?.toString() ?? '';
        _familyLoading = false;
      });
    }

    if (forceRefreshFamily) {
      ref.invalidate(currentFamilyProvider);
    }

    ref.read(currentFamilyProvider.future).then((family) {
      if (!mounted) return;
      setState(() {
        _familyData = family;
        _inviteCode = family?['invite_code']?.toString() ?? '';
        _familyLoading = false;
        _familyNetworkError = false;
      });
    }).catchError((e) {
      debugPrint('[ProfilePanelPage] ERROR: 家庭加载失败 $e');
      if (!mounted) return;
      setState(() {
        _familyData = null;
        _familyLoading = false;
        _familyNetworkError = true;
      });
    });

    try {
      final results = await Future.wait([
        ContributionService().getUserContribution(userId: userId),
        FamilyService().getUserFamilies(),
      ]);

      final contributionResult = results[0] as ApiResponse<Map<String, dynamic>>;
      final familiesResult = results[1] as ApiResponse<List<dynamic>>;

      if (!mounted) return;

      if (contributionResult.code == 200 && contributionResult.data != null) {
        setState(() {
          _contributionStats =
              UserContributionStats.fromApi(contributionResult.data);
          _contributionNetworkError = false;
        });
      } else {
        setState(() => _contributionStats = null);
      }

      if (familiesResult.code == 200) {
        setState(() {
          _families = familiesResult.data?.cast<Map<String, dynamic>>() ?? [];
        });
      }
    } catch (e) {
      debugPrint('[ProfilePanelPage] ERROR: 贡献/家庭列表 $e');
      if (!mounted) return;
      setState(() => _contributionNetworkError = true);
    } finally {
      if (mounted) setState(() => _contributionLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider.notifier).currentUser;
    final unreadAsync = ref.watch(unreadAlertCountProvider);
    final unreadCount = unreadAsync.value ?? 0;
    final statsAsync = ref.watch(homeStatsProvider);
    final stats = statsAsync.valueOrNull;
    final health = ProfileInventoryHealth.fromStats(stats);
    final pendingCount = stats == null
        ? 0
        : stats.expiredCount + stats.expiringCount + stats.lowStockCount;
    final skin = ref.watch(spaceSkinProvider);
    final role = ref.watch(familyRoleProvider);

    return WarmScaffold(
      title: '个人中心',
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _loadData(forceRefreshFamily: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ProfileFadeSlideIn(
              child: ProfileIdentityHeader(
                nickname: user?.nickname ?? '用户',
                phone: user?.phone ?? '',
                familyName: _familyData?['name']?.toString(),
                roleLabel: _roleLabel(role ?? user?.familyRole),
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
                    accentColor: pendingCount > 0
                        ? AppColors.danger
                        : AppColors.success,
                    urgent: pendingCount > 0,
                    onTap: () => context.push('/alerts'),
                  ),
                  ProfileOverviewTile(
                    label: '录入本月',
                    value: '${_contributionStats?.recordCount ?? 0}',
                    icon: CandyIcons.addBox,
                    accentColor: AppColors.success,
                    onTap: () => context.push('/profile/family/contribution'),
                  ),
                  ProfileOverviewTile(
                    label: '家庭物品',
                    value: '${_familyData?['item_count'] ?? 0}',
                    icon: CandyIcons.inventory,
                    accentColor: AppColors.primary,
                    onTap: () => context.push('/items'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: ProfileFamilyCard(
              familyName: _familyData?['name']?.toString(),
              members: (_familyData?['members'] as List?) ?? [],
              itemCount: (_familyData?['item_count'] as int?) ?? 0,
              inviteCode: _inviteCode,
              loading: _familyLoading,
              networkError: _familyNetworkError,
              onRetry: () => _loadData(forceRefreshFamily: true),
              onCreateFamily: () => context.push('/create-family'),
              onJoinFamily: () => context.push('/join-family'),
              onCopyInvite: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('邀请码已复制')),
                );
              },
              onRefreshInvite: ShopRoleGuard.canManageShop(skin, role)
                  ? _refreshInviteCode
                  : null,
              onManageMembers: ShopRoleGuard.canManageShop(skin, role)
                  ? () {
                      if (ShopRoleGuard.canChangeMemberRole(skin, role)) {
                        context.push('/profile/family/roles');
                      } else {
                        context.push('/profile/family');
                      }
                    }
                  : null,
              onSwitchFamily: _showSwitchFamily,
              ),
            ),
            const SizedBox(height: 16),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 180),
              child: ProfileContributionCard(
              stats: _contributionStats,
              loading: _contributionLoading,
              networkError: _contributionNetworkError,
              onRetry: () => _loadData(forceRefreshFamily: true),
              ),
            ),
            const SizedBox(height: 16),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 220),
              child: const FamilyContributionSection(),
            ),
            const SizedBox(height: 16),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 260),
              child: const AppSectionHeader(title: '常用功能'),
            ),
            const SizedBox(height: 10),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 280),
              child: ProfileQuickActionGrid(
                actions: buildProfileQuickActions(
                  context,
                  skin: skin,
                  unreadCount: unreadCount,
                  pendingCount: pendingCount,
                  familyRole: role,
                  compact: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ProfileFadeSlideIn(
              delay: const Duration(milliseconds: 320),
              child: _buildRealtimeSyncStatus(),
            ),
            const SizedBox(height: 16),
            if (ShopRoleGuard.canAccessProfileSettings(skin, role))
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    AppListRow(
                      icon: CandyIcons.settings,
                      accent: AppColors.accentRose,
                      title: '提醒设置',
                      onTap: () =>
                          context.push('/profile/notification-settings'),
                    ),
                    const AppListDivider(),
                    AppListRow(
                      icon: CandyIcons.checklist,
                      accent: AppColors.accentViolet,
                      title: '盘点任务',
                      onTap: () => context.push('/profile/inventory'),
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
                      icon: CandyIcons.palette,
                      accent: AppColors.accentAmber,
                      title: '主题样式',
                      onTap: () => context.push('/profile/theme-settings'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _showLogoutConfirm,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  '退出登录',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeSyncStatus() {
    final status = ref.watch(realtimeSyncStatusProvider);
    final (label, color, icon) = switch (status) {
      RealtimeSyncStatus.connected => (
          '实时同步已连接',
          AppColors.success,
          CandyIcons.cloudDone,
        ),
      RealtimeSyncStatus.connecting => (
          '正在连接实时同步…',
          AppColors.warning,
          CandyIcons.cloudSync,
        ),
      RealtimeSyncStatus.reconnecting => (
          '实时同步重连中…',
          AppColors.warning,
          CandyIcons.cloudSync,
        ),
      RealtimeSyncStatus.disconnected => (
          '实时同步未连接',
          AppColors.textHint,
          CandyIcons.cloudOff,
        ),
    };

    return AppCard(
      child: Row(
        children: [
          AppIcon.feature(
            icon: icon,
            accent: color,
            wellSize: 36,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '家庭同步',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshInviteCode() async {
    try {
      final familyId = (_familyData?['id'] as int?)?.toString() ?? '1';
      final result =
          await FamilyService().refreshInviteCode(familyId: familyId);
      if (result.code == 200 && mounted) {
        setState(() {
          _inviteCode = result.data?['invite_code'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('邀请码已刷新')),
        );
      }
    } catch (e) {
      debugPrint('[ProfilePanelPage] ERROR: 刷新邀请码 $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刷新失败: $e')),
        );
      }
    }
  }

  void _showLogoutConfirm() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出？'),
        content: const Text('退出后需要重新登录才能使用\n本地未同步的数据不会丢失'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('确认退出', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showSwitchFamily() {
    final user = ref.read(authProvider.notifier).currentUser;
    SwitchFamilyBottomSheet.show(
      context: context,
      families: _families,
      currentFamilyId: (_familyData?['id'] as dynamic)?.toString(),
      currentFamilyData: _familyData,
      userId: user?.id,
    ).then((_) => _loadData(forceRefreshFamily: true));
  }

  String? _roleLabel(String? role) {
    final isShop = ref.read(spaceSkinProvider).showSalePrice;
    return ShopRoleGuard.roleLabel(role, isShop: isShop);
  }
}
