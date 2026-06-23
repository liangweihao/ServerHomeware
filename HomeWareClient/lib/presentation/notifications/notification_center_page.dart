import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/notification_entry.dart';
import '../../core/providers/alert_provider.dart';
import '../../core/utils/alert_display_helper.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/shimmer_loading.dart';

/// 首页 AppBar 通知中心（Epic E1）
class NotificationCenterPage extends ConsumerWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(unreadNotificationsProvider);
    final unreadCountAsync = ref.watch(unreadAlertCountProvider);
    final unreadCount = unreadCountAsync.value ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('通知中心'),
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
      ),
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
                    return _NotificationListTile(
                      entry: entry,
                      alertTitle: info.title,
                      alertDescription: info.description,
                      iconData: info.iconData,
                      accentColor: info.color,
                      onTap: () {
                        debugPrint(
                          '[NotificationCenter] INFO: 跳转物品详情 id=${entry.item.id}',
                        );
                        context.push('/items/${entry.item.id}');
                      },
                    );
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
  final NotificationEntry entry;
  final String alertTitle;
  final String alertDescription;
  final IconData iconData;
  final Color accentColor;
  final VoidCallback onTap;

  const _NotificationListTile({
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

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(iconData, size: 22, color: accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.item.name} · $alertTitle',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alertDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: accentColor,
                              ),
                        ),
                        if (entry.locationPath != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            entry.locationPath!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textHint,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.chevron_right, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
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
