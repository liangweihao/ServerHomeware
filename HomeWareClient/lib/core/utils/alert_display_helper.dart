import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../constants/app_colors.dart';
import '../models/alert_type.dart';

/// 提醒展示文案与紧急度（通知中心 / AlertCard 共用）
class AlertDisplayInfo {
  final Color color;
  /// 兼容 AlertCard 等仍使用 emoji 的场景
  final String icon;
  /// Material Icon（通知中心等干净风 UI）
  final IconData iconData;
  final String title;
  final String description;
  final int urgency;

  const AlertDisplayInfo({
    required this.color,
    required this.icon,
    required this.iconData,
    required this.title,
    required this.description,
    required this.urgency,
  });
}

/// 提醒类型持久化键
String alertTypeToKey(AlertType type) {
  switch (type) {
    case AlertType.expiry:
      return 'expiry';
    case AlertType.stock:
      return 'stock';
    case AlertType.restock:
      return 'restock';
    case AlertType.warranty:
      return 'warranty';
    case AlertType.idle:
      return 'idle';
    case AlertType.other:
      return 'other';
  }
}

AlertType alertTypeFromKey(String key) {
  switch (key) {
    case 'expiry':
      return AlertType.expiry;
    case 'stock':
      return AlertType.stock;
    case 'restock':
      return AlertType.restock;
    case 'warranty':
      return AlertType.warranty;
    case 'idle':
      return AlertType.idle;
    default:
      return AlertType.other;
  }
}

/// 计算展示文案与紧急度（1–3，3 最紧急）
AlertDisplayInfo getAlertDisplayInfo(
  Item item,
  AlertType type, {
  String? descriptionOverride,
}) {
  final today = DateTime.now();

  switch (type) {
    case AlertType.expiry:
      if (item.expiryDate != null) {
        final daysLeft = item.expiryDate!.difference(today).inDays;
        if (daysLeft < 0) {
          return AlertDisplayInfo(
            color: AppColors.danger,
            icon: '🔴',
            iconData: Icons.event_busy_outlined,
            title: '已过期',
            description: '已过期${-daysLeft}天，请尽快处理',
            urgency: 3,
          );
        } else if (daysLeft <= 3) {
          return AlertDisplayInfo(
            color: AppColors.danger,
            icon: '🔴',
            iconData: Icons.schedule_outlined,
            title: '即将过期',
            description: '还剩$daysLeft天过期，尽快使用',
            urgency: 3,
          );
        } else if (daysLeft <= 7) {
          return AlertDisplayInfo(
            color: AppColors.warning,
            icon: '🟡',
            iconData: Icons.schedule_outlined,
            title: '注意',
            description: '还剩$daysLeft天过期',
            urgency: 2,
          );
        }
      }
      return const AlertDisplayInfo(
        color: AppColors.warning,
        icon: '🟡',
        iconData: Icons.schedule_outlined,
        title: '即将过期',
        description: '即将过期，请及时处理',
        urgency: 2,
      );

    case AlertType.stock:
      return AlertDisplayInfo(
        color: AppColors.warning,
        icon: '📦',
        iconData: Icons.inventory_2_outlined,
        title: '库存不足',
        description:
            '剩余${item.currentQuantity}${item.unit}，低于预警值${item.safetyStock}${item.unit}',
        urgency: 2,
      );

    case AlertType.restock:
      final updatedDays = today.difference(item.updatedAt).inDays;
      return AlertDisplayInfo(
        color: AppColors.primary,
        icon: '🛒',
        iconData: Icons.shopping_cart_outlined,
        title: '已用完',
        description: '$updatedDays天前用完，建议再次购买',
        urgency: 1,
      );

    case AlertType.warranty:
      if (item.warrantyDate != null) {
        final daysLeft = item.warrantyDate!.difference(today).inDays;
        return AlertDisplayInfo(
          color: AppColors.info,
          icon: '🔧',
          iconData: Icons.build_outlined,
          title: '保修即将到期',
          description: '还剩$daysLeft天保修到期',
          urgency: daysLeft <= 7 ? 2 : 1,
        );
      }
      return AlertDisplayInfo(
        color: AppColors.info,
        icon: '🔧',
        iconData: Icons.build_outlined,
        title: '保修即将到期',
        description: '保修即将到期',
        urgency: 1,
      );

    case AlertType.other:
      return AlertDisplayInfo(
        color: AppColors.info,
        icon: 'ℹ️',
        iconData: Icons.info_outline,
        title: '其他提醒',
        description: '有待处理的事项',
        urgency: 1,
      );

    case AlertType.idle:
      final ref = item.lastUsedAt ?? item.createdAt;
      final idleDays = today.difference(ref).inDays;
      final urgency = idleDays >= 90 ? 3 : idleDays >= 30 ? 2 : 1;
      return AlertDisplayInfo(
        color: AppColors.textHint,
        icon: '😴',
        iconData: Icons.hourglass_empty_outlined,
        title: '长期未使用',
        description: descriptionOverride?.trim().isNotEmpty == true
            ? descriptionOverride!.trim()
            : '已$idleDays天未记录使用动态',
        urgency: urgency,
      );
  }
}
