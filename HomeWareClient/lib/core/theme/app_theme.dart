import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'app_color_palette.dart';

/// Material 3 主题 — 颜色来自 [AppColors] / [AppColorPalette]
class AppTheme {
  /// 根据色板构建浅色主题
  static ThemeData lightThemeOf([AppColorPalette? palette]) {
    final p = palette ?? AppColors.activePalette;

    return ThemeData(
      useMaterial3: true,
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      cardColor: AppColors.card,
      dividerColor: AppColors.divider,
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

      // AppBar 主题
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.card,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
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
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
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
        backgroundColor: AppColors.card,
        selectedItemColor: p.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Divider 主题
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),

      // FloatingActionButton 主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),

      // 下拉刷新指示器
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
      ),
    );
  }

  /// 兼容旧引用，使用当前生效色板
  static ThemeData get lightTheme => lightThemeOf();
}
