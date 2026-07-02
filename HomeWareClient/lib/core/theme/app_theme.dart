import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'app_color_palette.dart';
import 'app_theme_extension.dart';
import 'app_theme_variant.dart';
import 'app_visual_style.dart';

/// Material 3 主题 — 支持卡通 / 工具风（点评+闲鱼向）
class AppTheme {
  /// 根据主题变体构建浅色主题
  static ThemeData lightThemeOf(AppThemeVariant variant) {
    return lightThemeFromPalette(variant.palette);
  }

  /// 根据色板构建浅色主题
  static ThemeData lightThemeFromPalette([AppColorPalette? palette]) {
    final p = palette ?? AppColors.activePalette;
    final isUtility = p.visualStyle == AppVisualStyle.utilityClean ||
        p.visualStyle == AppVisualStyle.vividClean;
    final isCartoon = p.visualStyle == AppVisualStyle.cartoon;
    final cardRadius = isUtility ? AppRadius.md : AppRadius.xl;
    final borderWidth = isCartoon ? 2.0 : 1.0;

    final baseTheme = ThemeData(
      useMaterial3: true,
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      cardColor: AppColors.card,
      dividerColor: AppColors.homeDivider,
      colorScheme: isUtility
          ? ColorScheme.light(
              primary: p.primary,
              onPrimary: AppColors.white,
              primaryContainer: AppColors.gray100,
              onPrimaryContainer: AppColors.textPrimary,
              secondary: AppColors.textSecondary,
              onSecondary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
              surfaceContainerHighest: AppColors.gray100,
              outline: AppColors.border,
              error: AppColors.danger,
              onError: AppColors.white,
            )
          : ColorScheme.fromSeed(
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
        AppThemeExtension(visualStyle: p.visualStyle),
      ],

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: isUtility ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: isCartoon
              ? BorderSide(color: p.primaryDark, width: 2)
              : BorderSide.none,
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isUtility ? AppColors.gray100 : AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isUtility ? AppRadius.sm : cardRadius),
          borderSide: BorderSide(color: AppColors.border, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isUtility ? AppRadius.sm : cardRadius),
          borderSide: BorderSide(color: AppColors.border, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isUtility ? AppRadius.sm : cardRadius),
          borderSide: BorderSide(color: p.primary, width: borderWidth),
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

      dividerTheme: DividerThemeData(
        color: AppColors.homeDivider,
        thickness: 1,
        space: 0,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isUtility ? AppColors.accentHighlight : p.primary,
        foregroundColor: isUtility ? AppColors.onAccentHighlight : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    );

    final textTheme = _buildTextTheme(baseTheme.textTheme, isCartoon: isCartoon);

    return baseTheme.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: isCartoon
              ? BorderSide(color: p.primaryDark, width: 2)
              : BorderSide.none,
        ),
        backgroundColor: AppColors.white,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: isCartoon
              ? BorderSide(color: p.primaryDark, width: 3)
              : BorderSide(color: AppColors.border, width: 1),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// 工具风用 Noto Sans SC，卡通用 Nunito 圆体
  static TextTheme _buildTextTheme(TextTheme base, {required bool isCartoon}) {
    if (isCartoon) {
      final nunito = GoogleFonts.nunitoTextTheme(base).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );
      return nunito.copyWith(
        titleLarge: nunito.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: nunito.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        titleSmall: nunito.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: nunito.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      );
    }

    return GoogleFonts.notoSansScTextTheme(base).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ).copyWith(
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 17,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
    );
  }

  /// 兼容旧引用，使用当前生效色板
  static ThemeData get lightTheme => lightThemeFromPalette();
}
