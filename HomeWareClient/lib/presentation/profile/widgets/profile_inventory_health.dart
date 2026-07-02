import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/home_provider.dart';

/// 家庭库存健康度 — 由首页统计推导
class ProfileInventoryHealth {
  const ProfileInventoryHealth({
    required this.score,
    required this.label,
    required this.hint,
    required this.color,
    required this.hasIssues,
  });

  final int score;
  final String label;
  final String hint;
  final Color color;
  final bool hasIssues;

  /// 头图渐变三色 — 随健康档变化
  List<Color> get headerGradientColors {
    if (score <= 0) {
      return [AppColors.gray100, AppColors.white, AppColors.gray100];
    }
    return [
      color.withValues(alpha: 0.18),
      AppColors.white,
      color.withValues(alpha: 0.1),
    ];
  }

  /// 头图装饰圆 / 点阵色
  Color get headerAccent => color.withValues(alpha: 0.1);

  /// 问候语强调色
  Color get greetingColor => score <= 0 ? AppColors.textHint : color;

  factory ProfileInventoryHealth.fromStats(HomeStats? stats) {
    if (stats == null) {
      return ProfileInventoryHealth(
        score: 0,
        label: '加载中',
        hint: '正在获取库存状态',
        color: AppColors.textHint,
        hasIssues: false,
      );
    }

    final penalty = stats.expiredCount * 12 +
        stats.expiringCount * 6 +
        stats.lowStockCount * 4;
    final score = (100 - penalty).clamp(35, 100);

    if (stats.expiredCount > 0) {
      return ProfileInventoryHealth(
        score: score,
        label: '需要关注',
        hint: '${stats.expiredCount} 件已过期，建议尽快处理',
        color: AppColors.danger,
        hasIssues: true,
      );
    }
    if (stats.expiringCount > 0 || stats.lowStockCount > 0) {
      final parts = <String>[];
      if (stats.expiringCount > 0) parts.add('${stats.expiringCount} 件临期');
      if (stats.lowStockCount > 0) parts.add('${stats.lowStockCount} 件需补货');
      return ProfileInventoryHealth(
        score: score,
        label: '尚可',
        hint: parts.join(' · '),
        color: AppColors.warning,
        hasIssues: true,
      );
    }

    return ProfileInventoryHealth(
      score: score,
      label: '状态良好',
      hint: '家里物品井井有条',
      color: AppColors.success,
      hasIssues: false,
    );
  }
}

/// 时段问候语
String profileTimeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 6) return '夜深了';
  if (hour < 11) return '早上好';
  if (hour < 14) return '中午好';
  if (hour < 18) return '下午好';
  return '晚上好';
}
