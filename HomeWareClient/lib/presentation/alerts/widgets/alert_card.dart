import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';

enum AlertType { expiry, stock, restock, warranty, other }

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
    final today = DateTime.now();

    switch (type) {
      case AlertType.expiry:
        if (item.expiryDate != null) {
          final daysLeft = item.expiryDate!.difference(today).inDays;
          if (daysLeft < 0) {
            return (AppColors.danger, '🔴', '已过期',
                '已过期${-daysLeft}天，存放于${item.locationId?.toString() ?? '未知位置'}');
          } else if (daysLeft <= 3) {
            return (AppColors.danger, '🔴', '即将过期',
                '还剩$daysLeft天过期，尽快使用');
          } else if (daysLeft <= 7) {
            return (AppColors.warning, '🟡', '注意',
                '还剩$daysLeft天过期');
          }
        }
        return (AppColors.warning, '🟡', '即将过期', '即将过期，请及时处理');

      case AlertType.stock:
        return (AppColors.warning, '📦', '库存不足',
            '剩余${item.currentQuantity}${item.unit}，低于预警值${item.safetyStock}${item.unit}');

      case AlertType.restock:
        final updatedDays = item.updatedAt != null
            ? today.difference(item.updatedAt!).inDays
            : 0;
        return (AppColors.primary, '🛒', '已用完',
            '${updatedDays}天前用完，建议再次购买');

      case AlertType.warranty:
        if (item.warrantyDate != null) {
          final daysLeft = item.warrantyDate!.difference(today).inDays;
          return (AppColors.info, '🔧', '保修即将到期',
              '还剩$daysLeft天保修到期');
        }
        return (AppColors.info, '🔧', '保修即将到期', '保修即将到期');

      case AlertType.other:
      default:
        return (AppColors.info, 'ℹ️', '其他提醒', '有待处理的事项');
    }
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
