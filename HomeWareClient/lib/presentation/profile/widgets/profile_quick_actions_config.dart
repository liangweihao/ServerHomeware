import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/shop_role_guard.dart';
import '../../../core/config/space_skin_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/icons/candy_icons.dart';
import '../../../core/models/space_type.dart';
import 'profile_quick_action_grid.dart';

/// 个人中心宫格快捷项配置 — Tab / Panel 共用（糖果轻点圆润图标）
List<ProfileQuickAction> buildProfileQuickActions(
  BuildContext context, {
  required SpaceSkinConfig skin,
  required int unreadCount,
  required int pendingCount,
  String? familyRole,
  bool compact = false,
}) {
  final items = <ProfileQuickAction>[
    ProfileQuickAction(
      icon: CandyIcons.inventory,
      label: '物品',
      subtitle: '浏览全部库存',
      tint: AppColors.accentCoral,
      highlight: true,
      onTap: () => context.push('/items'),
      shortcuts: [
        ProfileQuickShortcut(
          label: skin.addItemLabel,
          icon: CandyIcons.add,
          onTap: () => context.push('/items/add/method'),
        ),
        ProfileQuickShortcut(
          label: '扫码录入',
          icon: CandyIcons.qrScan,
          onTap: () => context.push('/items/scan'),
        ),
        if (skin.showSalePrice && ShopRoleGuard.canBulkImport(skin, familyRole))
          ProfileQuickShortcut(
            label: skin.csvImportTitle,
            icon: CandyIcons.table,
            onTap: () => context.push('/items/import/csv'),
          ),
        ProfileQuickShortcut(
          label: '物品列表',
          icon: CandyIcons.list,
          onTap: () => context.push('/items'),
        ),
      ],
    ),
    ProfileQuickAction(
      icon: CandyIcons.notifications,
      label: '提醒',
      subtitle: pendingCount > 0 ? '$pendingCount 项待处理' : '一切正常',
      tint: AppColors.danger,
      highlight: true,
      badge: unreadCount,
      onTap: () => context.push('/alerts'),
      shortcuts: [
        ProfileQuickShortcut(
          label: '临期提醒',
          icon: CandyIcons.schedule,
          onTap: () => context.push('/alerts?tab=expiry'),
        ),
        ProfileQuickShortcut(
          label: '低库存',
          icon: CandyIcons.stock,
          onTap: () => context.push('/alerts?tab=stock'),
        ),
        ProfileQuickShortcut(
          label: '全部提醒',
          icon: CandyIcons.notificationsActive,
          onTap: () => context.push('/alerts?tab=all'),
        ),
      ],
    ),
    ProfileQuickAction(
      icon: CandyIcons.campaign,
      label: '通知',
      tint: AppColors.accentSky,
      onTap: () => context.push('/notifications'),
      shortcuts: [
        ProfileQuickShortcut(
          label: '通知中心',
          icon: CandyIcons.inbox,
          onTap: () => context.push('/notifications'),
        ),
      ],
    ),
    ProfileQuickAction(
      icon: CandyIcons.barChart,
      label: '统计',
      tint: AppColors.accentSky,
      onTap: () => context.push('/statistics'),
      shortcuts: [
        ProfileQuickShortcut(
          label: '数据统计',
          icon: CandyIcons.insights,
          onTap: () => context.push('/statistics'),
        ),
      ],
    ),
  ];

  if (!compact) {
    items.addAll([
      ProfileQuickAction(
        icon: CandyIcons.shoppingCart,
        label: skin.spaceType == SpaceType.shop ? '采购' : '购物',
        tint: AppColors.accentAmber,
        onTap: () => context.push('/shopping'),
        shortcuts: [
          ProfileQuickShortcut(
            label: skin.shoppingListLabel,
            icon: CandyIcons.shoppingBag,
            onTap: () => context.push('/shopping'),
          ),
        ],
      ),
      ProfileQuickAction(
        icon: CandyIcons.checklist,
        label: '盘点',
        tint: AppColors.accentViolet,
        onTap: () => context.push('/profile/inventory'),
        shortcuts: [
          ProfileQuickShortcut(
            label: '盘点任务',
            icon: CandyIcons.factCheck,
            onTap: () => context.push('/profile/inventory'),
          ),
        ],
      ),
      ProfileQuickAction(
        icon: CandyIcons.groups,
        label: '协作',
        tint: AppColors.accentTeal,
        onTap: () => context.push('/profile/family/contribution'),
        shortcuts: [
          ProfileQuickShortcut(
            label: '贡献详情',
            icon: CandyIcons.leaderboard,
            onTap: () => context.push('/profile/family/contribution'),
          ),
          ProfileQuickShortcut(
            label: '家庭成员',
            icon: CandyIcons.people,
            onTap: () => context.push('/profile/family'),
          ),
        ],
      ),
      ProfileQuickAction(
        icon: CandyIcons.settings,
        label: '设置',
        tint: AppColors.textSecondary,
        onTap: () => context.push('/profile/notification-settings'),
        shortcuts: [
          ProfileQuickShortcut(
            label: '提醒设置',
            icon: CandyIcons.notificationsActive,
            onTap: () => context.push('/profile/notification-settings'),
          ),
        ],
      ),
    ]);
  }

  return items;
}
