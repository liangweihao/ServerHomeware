import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/models/notification_entry.dart';
import '../../core/models/alert_type.dart';
import '../../core/providers/alert_provider.dart';
import '../../core/utils/alert_display_helper.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/app_list_entrance.dart';
import '../common/widgets/cartoon_list_tile.dart';
import '../common/widgets/warm_scaffold.dart';
import '../common/widgets/shimmer_loading.dart';

/// 首页 AppBar 通知中心 — 工具风白卡列表 / 卡通双分支
class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(unreadNotificationsProvider);
    final unreadCountAsync = ref.watch(unreadAlertCountProvider);
    final unreadCount = unreadCountAsync.value ?? 0;

    return WarmScaffold(
      title: '通知中心',
      actions: [
        if (unreadCount > 0)
          TextButton(
            onPressed: () async {
              await markAllAlertsReadAction(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已标记所有提醒为已读')),
                );
              }
            },
            child: const Text('全部已读'),
          ),
      ],
      body: notificationsAsync.when(
        loading: () => const _NotificationLoadingList(),
        error: (error, _) {
          debugPrint('[NotificationCenter] ERROR: 加载失败 - $error');
          return Center(child: Text('加载失败: $error'));
        },
        data: (notifications) {
          if (notifications.isEmpty) {
            return _EmptyNotifications(onAddItem: () => context.push('/items/add'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  '今天 · $unreadCount 条未处理',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = notifications[index];
                    final type = alertTypeFromKey(entry.alertTypeKey);
                    final info = getAlertDisplayInfo(entry.item, type);
                    final tile = _NotificationListTile(
                      index: index,
                      entry: entry,
                      alertTitle: info.title,
                      alertDescription: info.description,
                      iconData: info.iconData,
                      accentColor: info.color,
                      onTap: () {
                        final alertKey = entry.alertTypeKey;
                        final detailUri = type == AlertType.expiry
                            ? '/items/${entry.item.id}?action=consume&alert=$alertKey'
                            : '/items/${entry.item.id}?alert=$alertKey';
                        debugPrint(
                          '[NotificationCenter] INFO: 跳转物品详情 id=${entry.item.id}',
                        );
                        context.push(detailUri);
                      },
                    );

                    if (AppColors.isUtilityStyle) return tile;
                    return AppListEntrance(index: index, child: tile);
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: AppButton(
                    label: '查看全部提醒',
                    variant: ButtonVariant.outline,
                    onPressed: () => context.go('/alerts'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 通知列表骨架屏
class _NotificationLoadingList extends StatelessWidget {
  const _NotificationLoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => const ShimmerNotificationTile(),
    );
  }
}

class _NotificationListTile extends StatelessWidget {
  final int index;
  final NotificationEntry entry;
  final String alertTitle;
  final String alertDescription;
  final IconData iconData;
  final Color accentColor;
  final VoidCallback onTap;

  const _NotificationListTile({
    required this.index,
    required this.entry,
    required this.alertTitle,
    required this.alertDescription,
    required this.iconData,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semanticsLabel =
        '${entry.item.name}，$alertTitle，$alertDescription'
        '${entry.locationPath != null ? '，${entry.locationPath}' : ''}';

    final subtitle = entry.locationPath != null
        ? '$alertDescription\n${entry.locationPath!}'
        : alertDescription;

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: AppColors.isUtilityStyle
          ? _buildUtilityTile(subtitle)
          : CartoonListTile(
              title: '${entry.item.name} · $alertTitle',
              subtitle: subtitle,
              leadingIcon: iconData,
              leadingColor: accentColor,
              colorIndex: index,
              onTap: onTap,
            ),
    );
  }

  /// 工具风通知行 — 白卡 + 左侧图标 + chevron
  Widget _buildUtilityTile(String subtitle) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.item.name} · $alertTitle',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  final VoidCallback onAddItem;

  const _EmptyNotifications({required this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppEmptyState(
              icon: '🎉',
              title: '暂无需要处理的事项',
              subtitle: '去添加物品或查看提醒设置',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  label: '添加物品',
                  size: ButtonSize.small32,
                  onPressed: onAddItem,
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: '提醒设置',
                  variant: ButtonVariant.outline,
                  size: ButtonSize.small32,
                  onPressed: () => context.push('/profile/notification-settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
