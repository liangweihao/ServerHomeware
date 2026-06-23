import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'app_color_palette.dart';
import 'app_decorations.dart';
import 'app_theme_extension.dart';
import 'app_theme_variant.dart';
import 'app_visual_style.dart';

/// Material 3 主题 — 颜色来自 [AppColors] / [AppThemeVariant]
class AppTheme {
  /// 根据主题变体构建浅色主题
  static ThemeData lightThemeOf(AppThemeVariant variant) {
    return lightThemeFromPalette(variant.palette);
  }

  /// 根据色板构建浅色主题
  static ThemeData lightThemeFromPalette([AppColorPalette? palette]) {
    final p = palette ?? AppColors.activePalette;
    final usesGradient = p.usesGradientBackground;
    final isNeumorph = p.visualStyle == AppVisualStyle.neumorphism;
    final appBarFg =
        usesGradient ? AppColors.white : AppColors.textPrimary;

    return ThemeData(
      useMaterial3: true,
      primaryColor: p.primary,
      scaffoldBackgroundColor:
          usesGradient ? Colors.transparent : p.background,
      cardColor: AppColors.card,
      dividerColor: isNeumorph
          ? AppDecorations.neumorphShadow.withValues(alpha: 0.35)
          : AppColors.divider,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: p.primary,
        onPrimary: AppColors.white,
        primaryContainer: p.primaryLighter,
        onPrimaryContainer: p.primaryDark,
        secondary: p.primaryLight,
        onSecondary: p.primaryDark,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
      ),
      extensions: [
        AppThemeExtension(
          visualStyle: p.visualStyle,
          gradientColors: p.gradientColors,
          useLightAppBarForeground: usesGradient,
        ),
      ],

      // AppBar 主题
      appBarTheme: AppBarTheme(
        backgroundColor: usesGradient
            ? Colors.transparent
            : (isNeumorph ? p.background : AppColors.white),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: appBarFg),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appBarFg,
        ),
      ),

      // Card 主题
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: EdgeInsets.zero,
      ),

      // InputDecoration 主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: usesGradient
            ? AppColors.white.withValues(alpha: 0.9)
            : (isNeumorph ? p.background : AppColors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isNeumorph ? Colors.transparent : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: isNeumorph ? Colors.transparent : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // BottomNavigationBar 主题
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: usesGradient
            ? AppColors.white.withValues(alpha: 0.18)
            : (isNeumorph ? p.background : AppColors.white),
        selectedItemColor: usesGradient ? AppColors.white : p.primary,
        unselectedItemColor: usesGradient
            ? AppColors.white.withValues(alpha: 0.65)
            : AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Divider 主题
      dividerTheme: DividerThemeData(
        color: isNeumorph
            ? AppDecorations.neumorphShadow.withValues(alpha: 0.35)
            : AppColors.divider,
        thickness: 1,
        space: 0,
      ),

      // FloatingActionButton 主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: isNeumorph ? 0 : 4,
        shape: const CircleBorder(),
      ),

      // 下拉刷新指示器
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: usesGradient ? AppColors.white : p.primary,
      ),
    );
  }

  /// 兼容旧引用，使用当前生效色板
  static ThemeData get lightTheme => lightThemeFromPalette();
}
