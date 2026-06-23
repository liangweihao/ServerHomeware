import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/alert_type.dart';
import '../../../core/utils/alert_display_helper.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';

export '../../../core/models/alert_type.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
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
                        Text(icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                title,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w500,
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
