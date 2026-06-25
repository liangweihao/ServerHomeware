import 'package:flutter/material.dart';
import '../../data/database/app_database.dart';
import '../constants/app_colors.dart';

/// 物品在列表中的「出现理由」— 回答用户「我为什么现在看它」
class ItemListReason {
  const ItemListReason({
    required this.emoji,
    required this.label,
    required this.color,
    required this.urgency,
  });

  final String emoji;
  final String label;
  final Color color;
  /// 紧急度 0–100，越高越需优先处理
  final int urgency;

  /// 是否属于「要处理」Tab
  bool get isActionable => urgency >= 50;
}

/// 计算物品列表出现理由与紧急度
ItemListReason computeItemListReason(Item item) {
  final now = DateTime.now();

  if (item.status == 3) {
    return const ItemListReason(
      emoji: '🗑️',
      label: '已丢弃',
      color: AppColors.textHint,
      urgency: 0,
    );
  }
  if (item.status == 1) {
    return const ItemListReason(
      emoji: '✓',
      label: '已用完',
      color: AppColors.textSecondary,
      urgency: 10,
    );
  }
  if (item.status == 2) {
    return const ItemListReason(
      emoji: '⏰',
      label: '已过期',
      color: AppColors.danger,
      urgency: 95,
    );
  }

  // 使用中：优先过期，其次库存
  if (item.expiryDate != null) {
    final daysLeft = item.expiryDate!.difference(now).inDays;
    if (daysLeft < 0) {
      return ItemListReason(
        emoji: '🔴',
        label: '已过期 ${-daysLeft} 天',
        color: AppColors.danger,
        urgency: 100,
      );
    }
    if (daysLeft <= 3) {
      return ItemListReason(
        emoji: '⚠️',
        label: '还剩 $daysLeft 天',
        color: AppColors.danger,
        urgency: 90,
      );
    }
    if (daysLeft <= 7) {
      return ItemListReason(
        emoji: '⏰',
        label: '还剩 $daysLeft 天',
        color: AppColors.warning,
        urgency: 75,
      );
    }
    if (daysLeft <= 30) {
      return ItemListReason(
        emoji: '📅',
        label: '还剩 $daysLeft 天',
        color: AppColors.warning,
        urgency: 40,
      );
    }
  }

  if (item.stockAlert &&
      item.currentQuantity <= item.safetyStock &&
      item.status == 0) {
    return ItemListReason(
      emoji: '📉',
      label: '库存不足',
      color: AppColors.warning,
      urgency: 80,
    );
  }

  final daysSinceCreated = now.difference(item.createdAt).inDays;
  if (daysSinceCreated <= 2) {
    return ItemListReason(
      emoji: '✨',
      label: '新添加',
      color: AppColors.primary,
      urgency: 15,
    );
  }

  return const ItemListReason(
    emoji: '✓',
    label: '库存充足',
    color: AppColors.success,
    urgency: 0,
  );
}

/// 按紧急度降序排序（相同紧急度按过期日、数量）
void sortItemsByUrgency(List<Item> items) {
  items.sort((a, b) {
    final ra = computeItemListReason(a);
    final rb = computeItemListReason(b);
    final cmp = rb.urgency.compareTo(ra.urgency);
    if (cmp != 0) return cmp;

    final ea = a.expiryDate;
    final eb = b.expiryDate;
    if (ea != null && eb != null) {
      return ea.compareTo(eb);
    }
    if (ea != null) return -1;
    if (eb != null) return 1;

    return a.currentQuantity.compareTo(b.currentQuantity);
  });
}

/// 解析物品所属空间分组名（顶级位置）
String resolveSpaceGroupName(Item item, Map<int, Location> locationById) {
  final locationId = item.locationId;
  if (locationId == null) return '未指定位置';

  final location = locationById[locationId];
  if (location == null) return '未指定位置';

  final segments = location.fullPath.split('/');
  return segments.isNotEmpty ? segments.first : location.name;
}
