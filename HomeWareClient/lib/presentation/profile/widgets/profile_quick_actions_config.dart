import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import 'profile_quick_action_grid.dart';

/// 个人中心宫格快捷项配置 — Tab / Panel 共用
List<ProfileQuickAction> buildProfileQuickActions(
  BuildContext context, {
  required int unreadCount,
  required int pendingCount,
  bool compact = false,
}) {
  final items = <ProfileQuickAction>[
    ProfileQuickAction(
      icon: Icons.inventory_2_outlined,
      label: '物品',
      subtitle: '浏览全部库存',
      tint: AppColors.accentCoral,
      highlight: true,
      onTap: () => context.push('/items'),
      shortcuts: [
        ProfileQuickShortcut(
          label: '添加入库',
          icon: Icons.add_circle_outline,
          onTap: () => context.push('/items/add/method'),
        ),
        ProfileQuickShortcut(
          label: '扫码录入',
          icon: Icons.qr_code_scanner_outlined,
          onTap: () => context.push('/items/scan'),
        ),
        ProfileQuickShortcut(
          label: '物品列表',
          icon: Icons.list_alt_outlined,
          onTap: () => context.push('/items'),
        ),
      ],
    ),
    ProfileQuickAction(
      icon: Icons.notifications_outlined,
      label: '提醒',
      subtitle: pendingCount > 0 ? '$pendingCount 项待处理' : '一切正常',
      tint: AppColors.danger,
      highlight: true,
      badge: unreadCount,
      onTap: () => context.push('/alerts'),
      shortcuts: [
        ProfileQuickShortcut(
          label: '临期提醒',
          icon: Icons.schedule_outlined,
          onTap: () => context.push('/alerts?tab=expiry'),
        ),
        ProfileQuickShortcut(
          label: '低库存',
          icon: Icons.inventory_outlined,
          onTap: () => context.push('/alerts?tab=stock'),
        ),
        ProfileQuickShortcut(
          label: '全部提醒',
          icon: Icons.notifications_active_outlined,
          onTap: () => context.push('/alerts?tab=all'),
        ),
      ],
    ),
    ProfileQuickAction(
      icon: Icons.campaign_outlined,
      label: '通知',
      tint: AppColors.accentSky,
      onTap: () => context.push('/notifications'),
      shortcuts: [
        ProfileQuickShortcut(
          label: '通知中心',
          icon: Icons.inbox_outlined,
          onTap: () => context.push('/notifications'),
        ),
      ],
    ),
    ProfileQuickAction(
      icon: Icons.bar_chart_outlined,
      label: '统计',
      tint: AppColors.accentSky,
      onTap: () => context.push('/statistics'),
      shortcuts: [
        ProfileQuickShortcut(
          label: '数据统计',
          icon: Icons.insights_outlined,
          onTap: () => context.push('/statistics'),
        ),
      ],
    ),
  ];

  if (!compact) {
    items.addAll([
      ProfileQuickAction(
        icon: Icons.shopping_cart_outlined,
        label: '购物',
        tint: AppColors.accentAmber,
        onTap: () => context.push('/shopping'),
        shortcuts: [
          ProfileQuickShortcut(
            label: '购物清单',
            icon: Icons.shopping_bag_outlined,
            onTap: () => context.push('/shopping'),
          ),
        ],
      ),
      ProfileQuickAction(
        icon: Icons.checklist_outlined,
        label: '盘点',
        tint: AppColors.accentViolet,
        onTap: () => context.push('/profile/inventory'),
        shortcuts: [
          ProfileQuickShortcut(
            label: '盘点任务',
            icon: Icons.fact_check_outlined,
            onTap: () => context.push('/profile/inventory'),
          ),
        ],
      ),
      ProfileQuickAction(
        icon: Icons.groups_outlined,
        label: '协作',
        tint: AppColors.accentTeal,
        onTap: () => context.push('/profile/family/contribution'),
        shortcuts: [
          ProfileQuickShortcut(
            label: '贡献详情',
            icon: Icons.leaderboard_outlined,
            onTap: () => context.push('/profile/family/contribution'),
          ),
          ProfileQuickShortcut(
            label: '家庭成员',
            icon: Icons.people_outline,
            onTap: () => context.push('/profile/family'),
          ),
        ],
      ),
      ProfileQuickAction(
        icon: Icons.settings_outlined,
        label: '设置',
        tint: AppColors.textSecondary,
        onTap: () => context.push('/profile/notification-settings'),
        shortcuts: [
          ProfileQuickShortcut(
            label: '提醒设置',
            icon: Icons.notifications_active_outlined,
            onTap: () => context.push('/profile/notification-settings'),
          ),
          ProfileQuickShortcut(
            label: '主题样式',
            icon: Icons.palette_outlined,
            onTap: () => context.push('/profile/theme-settings'),
          ),
        ],
      ),
    ]);
  }

  return items;
}
