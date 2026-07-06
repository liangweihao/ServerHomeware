import 'package:flutter/material.dart';
import '../theme/app_color_palette.dart';
import '../theme/app_visual_style.dart';

/// 糖果轻点颜色 Token（全局真源）
class AppColors {
  static AppColorPalette _active = AppColorPalettes.vividClean;

  static void applyPalette(AppColorPalette palette) {
    _active = palette;
  }

  static AppColorPalette get activePalette => _active;
  static AppVisualStyle get visualStyle => AppVisualStyle.vividClean;

  /// 是否糖果轻点（恒 true，保留兼容旧判断）
  static bool get isCandyStyle => true;

  @Deprecated('Use isCandyStyle')
  static bool get isUtilityStyle => true;

  @Deprecated('Use isCandyStyle')
  static bool get isVividCleanStyle => true;

  // 主色
  static Color get primary => _active.primary;
  static Color get primaryDark => _active.primaryDark;
  static Color get primaryLight => _active.primaryLight;
  static Color get primaryLighter => _active.primaryLighter;
  static String get primaryHex => _active.primaryHex;

  /// FAB / 首页「+」强调色 — 柔和蜜糖黄
  static const accentHighlight = Color(0xFFFFD166);
  static const onAccentHighlight = Color(0xFF4A3728);

  // 功能点缀色（宫格 / 标签映射）
  static const accentCoral = Color(0xFFFF6B5A);
  static const accentTeal = Color(0xFF2BB8A3);
  static const accentSky = Color(0xFF4A9FE8);
  static const accentViolet = Color(0xFF8B7FD4);
  static const accentAmber = Color(0xFFF5A623);
  static const accentRose = Color(0xFFE85D8A);

  static Color get reasonLowStock => accentSky;

  static const success = Color(0xFF43A047);
  static const successLight = Color(0xFFE8F5E9);
  static const warning = Color(0xFFFF9800);
  static const warningLight = Color(0xFFFFF3E0);
  static const danger = Color(0xFFEF5350);
  static const dangerLight = Color(0xFFFFEBEE);

  static Color get info => _active.info;
  static Color get infoLight => _active.infoLight;
  static Color get background => _active.background;
  static Color get scaffoldBackground => _active.background;
  static Color get appBarBackground => white;
  static const white = Color(0xFFFFFFFF);

  static Color get card => white;

  // 文字 — 暖灰，避免纯黑
  static const textPrimary = Color(0xFF3D3A36);
  static const textSecondary = Color(0xFF6B6560);
  static const textHint = Color(0xFF9E9890);
  static const appBarForeground = textPrimary;

  static Color get sectionBackground => white;
  static Color get homeDivider => const Color(0xFFF0EBE6);
  static Color get cartoonBorder => primaryLight;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF6B6560).withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static Color get iconWellBackground => gray100;
  static Color get infoBannerBackground => primaryLighter;
  static Color get chipBackground => white;
  static Color get chipSelectedBackground => primaryLighter;

  static Color tagBackgroundFor(Color color) =>
      color.withValues(alpha: 0.14);

  /// 饱和圆角底 + 白图标
  static (Color background, Color foreground) iconWellFor(Color accent) {
    final fill = accent == textSecondary || accent == textHint
        ? gray500
        : accent;
    return (fill, white);
  }

  static const divider = Color(0xFFF0EBE6);
  static const border = Color(0xFFE8E2DC);
  static const disabled = Color(0xFFCFC8C0);

  static const gray50 = Color(0xFFFAF8F6);
  static const gray100 = Color(0xFFF5F1EC);
  static const gray200 = Color(0xFFEBE5DE);
  static const gray300 = Color(0xFFE0D9D1);
  static const gray400 = Color(0xFFCFC8C0);
  static const gray500 = Color(0xFF9E9890);
  static const gray700 = Color(0xFF6B6560);
  static const gray900 = Color(0xFF3D3A36);

  // 分类色（独立于主色）
  static const categoryFood = Color(0xFFFF8A65);
  static const categoryDaily = Color(0xFF4DB6AC);
  static const categoryMedicine = Color(0xFF7986CB);
  static const categoryElectronics = Color(0xFFFFD54F);
  static const categoryClothing = Color(0xFFF06292);
  static const categoryOther = Color(0xFFA1887F);

  static const shimmerBase = Color(0xFFE8E2DC);
  static const shimmerHighlight = Color(0xFFF5F1EC);
}
