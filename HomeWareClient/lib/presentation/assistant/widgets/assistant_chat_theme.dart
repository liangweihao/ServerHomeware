import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_typography.dart';

/// 问管管页 — Candy Light 视觉 Token（气泡 / 卡片 / 间距）
abstract final class AssistantChatTheme {
  /// 管管侧头像尺寸
  static const mascotSize = 34.0;

  /// 头像与内容区间距
  static const avatarGap = 10.0;

  /// 一轮对话底部间距
  static const turnSpacing = 16.0;

  /// 管管气泡 — 暖珊瑚浅底，无硬描边
  static BoxDecoration get assistantBubbleDecoration => BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.sm),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCoral.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      );

  /// 用户气泡 — 主色填充 + 轻阴影
  static BoxDecoration get userBubbleDecoration => BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.sm),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// 物品卡片 — 白底轻阴影
  static BoxDecoration get itemCardDecoration => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppColors.cardShadow,
      );

  /// 管管正文
  static TextStyle get assistantBody => AppTypography.bodyLarge.copyWith(
        height: 1.55,
        color: AppColors.textPrimary,
      );

  /// 用户正文
  static TextStyle get userBody => AppTypography.bodyLarge.copyWith(
        height: 1.5,
        color: AppColors.white,
        fontWeight: FontWeight.w600,
      );

  /// 物品卡片标题
  static TextStyle get itemTitle => AppTypography.titleMedium;

  /// 物品卡片副标题
  static TextStyle get itemSubtitle => AppTypography.bodySmall;

  /// 建议 Chip 文案
  static TextStyle get chipLabel => AppTypography.labelLarge.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
