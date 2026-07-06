import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 糖果轻点字体层级 — 配合 ThemeData.textTheme 使用
abstract final class AppTypography {
  static TextStyle get displayLarge => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.15,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineLarge => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textHint,
      );
}
