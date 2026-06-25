import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/models/alert_type.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/alert_display_helper.dart';
import '../../../core/theme/cartoon_decorations.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/cartoon_ui.dart';

export '../../../core/models/alert_type.dart';

/// 提醒卡片 — 贴纸外框 + 内容级 emoji 图标与标签
class AlertCard extends StatelessWidget {
  final Item item;
  final AlertType type;
  final VoidCallback? onUse;
  final VoidCallback? onDiscard;
  final VoidCallback? onAddToShopping;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onIgnore;

  const AlertCard({
    super.key,
    required this.item,
    required this.type,
    this.onUse,
    this.onDiscard,
    this.onAddToShopping,
    this.onAcknowledge,
    this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, title, description) = _getAlertInfo();

    return AppSurface(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  bottomLeft: Radius.circular(AppRadius.xl),
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
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color, width: 2.5),
                          ),
                          child: Text(icon, style: const TextStyle(fontSize: 20, height: 1)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              CartoonStickerBadge(
                                label: title,
                                accentColor: color,
                                fontSize: 10,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, String, String, String) _getAlertInfo() {
    final info = getAlertDisplayInfo(item, type);
    return (info.color, info.icon, info.title, info.description);
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];

    switch (type) {
      case AlertType.expiry:
        if (onUse != null) {
          buttons.add(
            AppButton(
              label: '今天用掉',
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
              label: '已丢弃',
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
              label: '加入购物清单',
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
              label: '加入购物清单',
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

    return Row(children: buttons);
  }
}
