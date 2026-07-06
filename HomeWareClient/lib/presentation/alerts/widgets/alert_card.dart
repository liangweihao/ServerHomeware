import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/models/alert_type.dart';
import '../../../core/config/space_skin_config.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/utils/alert_display_helper.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_reason_tag.dart';

export '../../../core/models/alert_type.dart';

/// 提醒卡片 — 工具风白底 + 左侧色条 + AppReasonTag 标签
class AlertCard extends ConsumerWidget {
  final Item item;
  final AlertType type;
  final VoidCallback? onUse;
  final VoidCallback? onDiscard;
  final VoidCallback? onAddToShopping;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onIgnore;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.item,
    required this.type,
    this.onTap,
    this.onUse,
    this.onDiscard,
    this.onAddToShopping,
    this.onAcknowledge,
    this.onIgnore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(spaceSkinProvider);
    final info = getAlertDisplayInfo(item, type);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: info.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.md),
                    bottomLeft: Radius.circular(AppRadius.md),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildIcon(info),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                AppReasonTag.plain(
                                  label: info.title,
                                  color: info.color,
                                  emoji: info.icon,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        info.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButtons(context, skin),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 提醒类型图标 — 工具风用 Material Icon，卡通主题保留 emoji
  Widget _buildIcon(AlertDisplayInfo info) {
    if (AppColors.isUtilityStyle) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: info.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: CandyIcon(info.iconData, color: info.color, size: 22),
      );
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: info.color, width: 2),
      ),
      child: Text(info.icon, style: const TextStyle(fontSize: 20, height: 1)),
    );
  }

  Widget _buildActionButtons(BuildContext context, SpaceSkinConfig skin) {
    final buttons = <Widget>[];

    switch (type) {
      case AlertType.expiry:
        if (onUse != null) {
          buttons.add(
            AppButton(
              label: skin.alertUseTodayLabel,
              variant: ButtonVariant.secondary,
              size: ButtonSize.small32,
              onPressed: onUse,
            ),
          );
        }
        if (onDiscard != null) {
          buttons.add(const SizedBox(width: 8));
          buttons.add(
            AppButton(
              label: skin.discardShortLabel,
              variant: ButtonVariant.outline,
              size: ButtonSize.small32,
              onPressed: onDiscard,
            ),
          );
        }
        if (onIgnore != null) {
          buttons.add(const SizedBox(width: 8));
          buttons.add(
            AppButton(
              label: '忽略',
              variant: ButtonVariant.ghost,
              size: ButtonSize.small32,
              onPressed: onIgnore,
            ),
          );
        }
        break;

      case AlertType.stock:
        if (onAddToShopping != null) {
          buttons.add(
            AppButton(
              label: skin.addToShoppingLabel,
              variant: ButtonVariant.primary,
              size: ButtonSize.small32,
              onPressed: onAddToShopping,
            ),
          );
        }
        if (onAcknowledge != null) {
          buttons.add(const SizedBox(width: 8));
          buttons.add(
            AppButton(
              label: '已知晓',
              variant: ButtonVariant.ghost,
              size: ButtonSize.small32,
              onPressed: onAcknowledge,
            ),
          );
        }
        break;

      case AlertType.restock:
        if (onAddToShopping != null) {
          buttons.add(
            AppButton(
              label: skin.addToShoppingLabel,
              variant: ButtonVariant.primary,
              size: ButtonSize.small32,
              onPressed: onAddToShopping,
            ),
          );
        }
        break;

      case AlertType.warranty:
      case AlertType.other:
        if (onAcknowledge != null) {
          buttons.add(
            AppButton(
              label: '已知晓',
              variant: ButtonVariant.outline,
              size: ButtonSize.small32,
              onPressed: onAcknowledge,
            ),
          );
        }
        break;
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: buttons,
    );
  }
}
