import 'package:flutter/material.dart';
import '../theme/app_color_palette.dart';
import '../theme/app_visual_style.dart';

/// 应用颜色常量（全局 Token 真源）
class AppColors {
  static AppColorPalette _active = AppColorPalettes.utilityClean;

  /// 应用指定色板（启动时调用）
  static void applyPalette(AppColorPalette palette) {
    _active = palette;
  }

  /// 当前生效的主色色板
  static AppColorPalette get activePalette => _active;

  /// 当前视觉风格
  static AppVisualStyle get visualStyle => _active.visualStyle;

  /// 是否工具风（点评/闲鱼/糖果轻点向）
  static bool get isUtilityStyle =>
      visualStyle == AppVisualStyle.utilityClean ||
      visualStyle == AppVisualStyle.communityWarm ||
      visualStyle == AppVisualStyle.vividClean;

  /// 是否糖果轻点主题（饱和图标底 + 白图标）
  static bool get isVividCleanStyle =>
      visualStyle == AppVisualStyle.vividClean;

  // 主色 — 随色板切换
  static Color get primary => _active.primary;
  static Color get primaryDark => _active.primaryDark;
  static Color get primaryLight => _active.primaryLight;
  static Color get primaryLighter => _active.primaryLighter;
  static String get primaryHex => _active.primaryHex;

  /// 闲鱼向强调色 — 首页「+」等关键操作
  static const accentHighlight = Color(0xFFFFDA44);

  /// 强调色上的前景（深灰，保证黄底可读）
  static const onAccentHighlight = Color(0xFF333333);

  // —— 糖果轻点功能点缀色（固定映射，全站一致）——
  static const accentCoral = Color(0xFFFF6B5A);
  static const accentTeal = Color(0xFF2BB8A3);
  static const accentSky = Color(0xFF4A9FE8);
  static const accentViolet = Color(0xFF8B7FD4);
  static const accentAmber = Color(0xFFF5A623);
  static const accentRose = Color(0xFFE85D8A);

  /// 列表「库存不足」理由色 — 糖果轻点用天蓝更醒目
  static Color get reasonLowStock =>
      isVividCleanStyle ? accentSky : warning;

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

  /// AppBar 背景 — 工具风用白顶栏，与点评/闲鱼一致
  static Color get appBarBackground =>
      isUtilityStyle ? white : _active.background;

  // 白色
  static const white = Color(0xFFFFFFFF);

  // 卡片背景
  static Color get card => white;

  // 文字颜色 — 中性灰（点评/闲鱼），保持 const 供全站 const 组件使用
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);

  /// AppBar 标题/图标色
  static const appBarForeground = textPrimary;

  /// 模块分区底 — 工具风/糖果轻点白底卡片区
  static Color get sectionBackground =>
      visualStyle == AppVisualStyle.utilityClean ||
              visualStyle == AppVisualStyle.vividClean
          ? white
          : _active.primaryLighter;

  /// 顶栏/卡片分割线
  static Color get homeDivider =>
      isUtilityStyle ? const Color(0xFFEEEEEE) : const Color(0xFFEDE6DC);

  /// 卡通主题边框色
  static Color get cartoonBorder => _active.primaryLight;

  /// 卡片轻投影 — 工具风以描边为主，阴影极轻
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isUtilityStyle ? 0.04 : 0.08),
          blurRadius: isUtilityStyle ? 6 : 12,
          offset: Offset(0, isUtilityStyle ? 1 : 4),
        ),
      ];

  /// 工具风图标底 — 中性灰，避免整页橙/黄底
  static Color get iconWellBackground =>
      isUtilityStyle ? gray100 : primaryLighter;

  /// 工具风提示条底
  static Color get infoBannerBackground =>
      isUtilityStyle ? gray50 : primaryLighter;

  /// 工具风 Chip 未选中底
  static Color get chipBackground =>
      isUtilityStyle ? white : primaryLighter;

  /// 工具风 Chip 选中底
  static Color get chipSelectedBackground =>
      isUtilityStyle ? gray50 : primaryLighter;

  /// 标签 Pill 浅色底 — 糖果轻点略提高饱和度感知
  static Color tagBackgroundFor(Color color) {
    return color.withValues(alpha: isVividCleanStyle ? 0.14 : 0.12);
  }

  /// 功能图标容器 — 糖果轻点：饱和底+白标；工具风：灰底+彩标
  static (Color background, Color foreground) iconWellFor(Color accent) {
    if (isVividCleanStyle) {
      final fill = accent == textSecondary || accent == textHint
          ? gray500
          : accent;
      return (fill, white);
    }
    if (visualStyle == AppVisualStyle.utilityClean ||
        visualStyle == AppVisualStyle.communityWarm) {
      return (gray100, accent);
    }
    return (accent.withValues(alpha: 0.12), accent);
  }

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
