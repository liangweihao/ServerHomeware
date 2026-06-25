import 'package:flutter/material.dart';
import '../theme/app_color_palette.dart';
import '../theme/app_visual_style.dart';

/// 应用颜色常量（全局 Token 真源）
///
/// 当前固定为卡通主题色板，语义色与分类色保持独立。
class AppColors {
  static AppColorPalette _active = AppColorPalettes.cartoon;

  /// 应用指定色板（启动时调用）
  static void applyPalette(AppColorPalette palette) {
    _active = palette;
  }

  /// 当前生效的主色色板
  static AppColorPalette get activePalette => _active;

  /// 当前视觉风格
  static AppVisualStyle get visualStyle => _active.visualStyle;

  // 主色 — 随色板切换
  static Color get primary => _active.primary;
  static Color get primaryDark => _active.primaryDark;
  static Color get primaryLight => _active.primaryLight;
  static Color get primaryLighter => _active.primaryLighter;
  static String get primaryHex => _active.primaryHex;

  // 成功/正常
  static const success = Color(0xFF4CAF50);
  static const successLight = Color(0xFFE8F5E9);

  // 警告/注意
  static const warning = Color(0xFFFF9800);
  static const warningLight = Color(0xFFFFF3E0);

  // 危险/过期
  static const danger = Color(0xFFF44336);
  static const dangerLight = Color(0xFFFFEBEE);

  // 信息/其他 — 与主色统一
  static Color get info => _active.info;
  static Color get infoLight => _active.infoLight;

  // 页面背景
  static Color get background => _active.background;

  /// Scaffold / 滚动区域背景
  static Color get scaffoldBackground => _active.background;

  /// AppBar 背景
  static Color get appBarBackground => _active.background;

  // 白色
  static const white = Color(0xFFFFFFFF);

  // 卡片背景
  static Color get card => white;

  // 文字颜色
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF616161);
  static const textHint = Color(0xFF9E9E9E);

  /// AppBar 标题/图标色
  static Color get appBarForeground => textPrimary;

  /// 卡通主题边框色
  static Color get cartoonBorder => _active.primaryLight;

  // 分割线和边框
  static const divider = Color(0xFFEEEEEE);
  static const border = Color(0xFFE0E0E0);

  // 禁用状态
  static const disabled = Color(0xFFBDBDBD);

  // 完整的灰色体系
  static const gray50 = Color(0xFFFAFAFA);
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray700 = Color(0xFF616161);
  static const gray900 = Color(0xFF212121);

  // 分类颜色（独立于主色，勿随全局换色修改）
  static const categoryFood = Color(0xFFFF8A65);
  static const categoryDaily = Color(0xFF4DB6AC);
  static const categoryMedicine = Color(0xFF7986CB);
  static const categoryElectronics = Color(0xFFFFD54F);
  static const categoryClothing = Color(0xFFF06292);
  static const categoryOther = Color(0xFFA1887F);

  // 骨架屏颜色
  static const shimmerBase = Color(0xFFE0E0E0);
  static const shimmerHighlight = Color(0xFFF5F5F5);
}
