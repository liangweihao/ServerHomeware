import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/models/alert_type.dart';
import '../../../core/utils/alert_display_helper.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/tag_chip.dart';
import 'usage_dialog.dart';

/// 物品详情顶部提醒上下文 — 从提醒/通知进入时展示快捷处理
class ItemAlertContextBanner extends ConsumerWidget {
  const ItemAlertContextBanner({
    super.key,
    required this.item,
    required this.alertType,
    required this.onHandled,
  });

  final Item item;
  final AlertType alertType;
  final VoidCallback onHandled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = getAlertDisplayInfo(item, alertType);
    final canConsume =
        alertType == AlertType.expiry && item.status == 0 && item.currentQuantity > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: info.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(info.iconData, size: 20, color: info.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '来自提醒 · ${info.title}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TagChip(
                label: info.title,
                color: info.color,
                background: info.color.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            info.description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          if (canConsume) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(
                  label: '记 1 件',
                  size: ButtonSize.small32,
                  onPressed: () => _quickConsume(context, ref),
                ),
                AppButton(
                  label: '记录使用',
                  variant: ButtonVariant.outline,
                  size: ButtonSize.small32,
                  onPressed: () => _openUsageDialog(context, ref),
                ),
                AppButton(
                  label: '已丢弃',
                  variant: ButtonVariant.ghost,
                  size: ButtonSize.small32,
                  onPressed: () => _discard(context, ref),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _quickConsume(BuildContext context, WidgetRef ref) async {
    debugPrint('[ItemAlertBanner] INFO: 快捷记 1 件 itemId=${item.id}');
    final ok = await recordQuickUsage(ref: ref, item: item);
    if (!context.mounted) return;
    if (ok) {
      onHandled();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已记录使用 1 件${item.name}')),
      );
    }
  }

  Future<void> _openUsageDialog(BuildContext context, WidgetRef ref) async {
    await showUsageDialog(
      context: context,
      ref: ref,
      item: item,
      onCompleted: () {
        if (context.mounted) {
          onHandled();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已记录使用')),
          );
        }
      },
    );
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认丢弃？'),
        content: Text('将丢弃「${item.name}」'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('丢弃', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    debugPrint('[ItemAlertBanner] INFO: 丢弃 itemId=${item.id}');
    await recordItemDiscard(ref: ref, item: item);
    if (!context.mounted) return;
    onHandled();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} 已标记为丢弃')),
    );
  }
}
