import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'app_color_palette.dart';
import 'app_theme_extension.dart';
import 'app_theme_variant.dart';
import 'app_visual_style.dart';

/// Material 3 主题 — 卡通轻插画风格
class AppTheme {
  /// 根据主题变体构建浅色主题
  static ThemeData lightThemeOf(AppThemeVariant variant) {
    return lightThemeFromPalette(variant.palette);
  }

  /// 根据色板构建浅色主题
  static ThemeData lightThemeFromPalette([AppColorPalette? palette]) {
    final p = palette ?? AppColors.activePalette;
    const cardRadius = AppRadius.xl;

    final baseTheme = ThemeData(
      useMaterial3: true,
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      cardColor: AppColors.card,
      dividerColor: p.primaryLight.withValues(alpha: 0.5),
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
        AppThemeExtension(visualStyle: AppVisualStyle.cartoon),
      ],

      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: p.primaryLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: p.primaryLight, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: p.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );

    // Nunito 圆体 + 加粗标题
    final nunito = GoogleFonts.nunitoTextTheme(baseTheme.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    return baseTheme.copyWith(
      textTheme: nunito.copyWith(
        titleLarge: nunito.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: nunito.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        titleSmall: nunito.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: nunito.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      primaryTextTheme: nunito,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: p.primaryDark, width: 2),
        ),
        backgroundColor: AppColors.white,
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: p.primaryDark, width: 3),
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// 兼容旧引用，使用当前生效色板
  static ThemeData get lightTheme => lightThemeFromPalette();
}
