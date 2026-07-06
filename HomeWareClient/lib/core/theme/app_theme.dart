import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_typography.dart';
import 'app_color_palette.dart';
import 'app_theme_extension.dart';
import 'app_theme_variant.dart';
import 'app_visual_style.dart';

/// 糖果轻点 Material 3 主题
class AppTheme {
  static ThemeData lightThemeOf(AppThemeVariant variant) {
    return lightThemeFromPalette(variant.palette);
  }

  static ThemeData lightThemeFromPalette([AppColorPalette? palette]) {
    final p = palette ?? AppColors.activePalette;
    const cardRadius = AppRadius.lg;

    final baseTheme = ThemeData(
      useMaterial3: true,
      primaryColor: p.primary,
      scaffoldBackgroundColor: p.background,
      cardColor: AppColors.card,
      dividerColor: AppColors.homeDivider,
      colorScheme: ColorScheme.light(
        primary: p.primary,
        onPrimary: AppColors.white,
        primaryContainer: p.primaryLighter,
        onPrimaryContainer: p.primaryDark,
        secondary: AppColors.accentTeal,
        onSecondary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.gray100,
        outline: AppColors.border,
        error: AppColors.danger,
        onError: AppColors.white,
      ),
      extensions: const [
        AppThemeExtension(visualStyle: AppVisualStyle.vividClean),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray100,
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        labelStyle: AppTypography.labelLarge,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.accentCoral,
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
        backgroundColor: AppColors.accentHighlight,
        foregroundColor: AppColors.onAccentHighlight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
      ),
    );

    final textTheme = _buildTextTheme(baseTheme.textTheme);

    return baseTheme.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: textTheme.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        backgroundColor: AppColors.white,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        labelStyle: textTheme.labelSmall,
      ),
    );
  }

  /// 糖果轻点 — Nunito 圆体
  static TextTheme _buildTextTheme(TextTheme base) {
    final nunito = GoogleFonts.nunitoTextTheme(base).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
    return nunito.copyWith(
      displayLarge: AppTypography.displayLarge.copyWith(fontFamily: nunito.displayLarge?.fontFamily),
      displayMedium: AppTypography.displayMedium.copyWith(fontFamily: nunito.displayMedium?.fontFamily),
      headlineLarge: AppTypography.headlineLarge.copyWith(fontFamily: nunito.headlineLarge?.fontFamily),
      headlineMedium: AppTypography.headlineMedium.copyWith(fontFamily: nunito.headlineMedium?.fontFamily),
      titleLarge: AppTypography.titleLarge.copyWith(fontFamily: nunito.titleLarge?.fontFamily),
      titleMedium: AppTypography.titleMedium.copyWith(fontFamily: nunito.titleMedium?.fontFamily),
      bodyLarge: AppTypography.bodyLarge.copyWith(fontFamily: nunito.bodyLarge?.fontFamily),
      bodyMedium: AppTypography.bodyMedium.copyWith(fontFamily: nunito.bodyMedium?.fontFamily),
      bodySmall: AppTypography.bodySmall.copyWith(fontFamily: nunito.bodySmall?.fontFamily),
      labelLarge: AppTypography.labelLarge.copyWith(fontFamily: nunito.labelLarge?.fontFamily),
      labelSmall: AppTypography.labelSmall.copyWith(fontFamily: nunito.labelSmall?.fontFamily),
    );
  }

  static ThemeData get lightTheme => lightThemeFromPalette();
}
