import 'package:flutter/material.dart';
import 'app_visual_style.dart';

/// 可切换的应用主色色板（主色及衍生色，不含语义色与分类色）
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryLighter,
    required this.primaryHex,
    required this.background,
    this.visualStyle = AppVisualStyle.standard,
    this.gradientColors,
  });

  /// 主色
  final Color primary;

  /// 主色深色（按钮按下、强调文字）
  final Color primaryDark;

  /// 主色浅色（次要强调）
  final Color primaryLight;

  /// 主色极浅（容器背景、选中态底）
  final Color primaryLighter;

  /// 主色十六进制字符串
  final String primaryHex;

  /// 页面背景（标准主题使用；特殊主题作渐变回退色）
  final Color background;

  /// 视觉风格（玻璃 / 渐变等）
  final AppVisualStyle visualStyle;

  /// 渐变背景色列表（仅 glassmorphism / gradientBold 使用）
  final List<Color>? gradientColors;

  /// 信息色与主色统一
  Color get info => primary;

  /// 信息浅色底与主色极浅统一
  Color get infoLight => primaryLighter;

  /// 是否使用特殊视觉风格
  bool get isStyledTheme => visualStyle != AppVisualStyle.standard;

  /// 是否使用渐变底（玻璃 / 渐变活力）
  bool get usesGradientBackground => visualStyle.usesGradientBackground;
}

/// 预设色板集合（仅保留三种特效主题）
abstract final class AppColorPalettes {
  /// 玻璃拟态 — 紫蓝渐变底 + 磨砂半透明卡片
  static const glassmorphism = AppColorPalette(
    primary: Color(0xFFCE93D8),
    primaryDark: Color(0xFF7E57C2),
    primaryLight: Color(0xFFE1BEE7),
    primaryLighter: Color(0x40FFFFFF),
    primaryHex: '#667EEA',
    background: Color(0xFF667EEA),
    visualStyle: AppVisualStyle.glassmorphism,
    gradientColors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
    ],
  );

  /// 渐变活力 — 紫粉橙渐变底 + 高对比强调
  static const gradientBold = AppColorPalette(
    primary: Color(0xFFFF4081),
    primaryDark: Color(0xFFC51162),
    primaryLight: Color(0xFFFF80AB),
    primaryLighter: Color(0x33FFFFFF),
    primaryHex: '#7C4DFF',
    background: Color(0xFF7C4DFF),
    visualStyle: AppVisualStyle.gradientBold,
    gradientColors: [
      Color(0xFF7C4DFF),
      Color(0xFFFF5722),
    ],
  );

  /// 新拟态轻质感（默认）— 灰白同色系 + 软阴影浮雕
  static const neumorphism = AppColorPalette(
    primary: Color(0xFF3A9B8A),
    primaryDark: Color(0xFF2D7F71),
    primaryLight: Color(0xFFA8D5CC),
    primaryLighter: Color(0xFFDCE8E5),
    primaryHex: '#E8ECF0',
    background: Color(0xFFE8ECF0),
    visualStyle: AppVisualStyle.neumorphism,
  );
}
