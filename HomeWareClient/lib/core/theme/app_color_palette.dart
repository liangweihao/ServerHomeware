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
    this.visualStyle = AppVisualStyle.cartoon,
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

  /// 页面背景
  final Color background;

  /// 视觉风格
  final AppVisualStyle visualStyle;

  /// 信息色与主色统一
  Color get info => primary;

  /// 信息浅色底与主色极浅统一
  Color get infoLight => primaryLighter;

  /// 是否使用特殊视觉风格
  bool get isStyledTheme => true;

  /// 是否使用渐变底
  bool get usesGradientBackground => false;
}

/// 预设色板
abstract final class AppColorPalettes {
  /// 卡通轻插画 — 暖米白底 + 珊瑚主色 + 描边卡片
  static const cartoon = AppColorPalette(
    primary: Color(0xFFFF8A65),
    primaryDark: Color(0xFFE64A19),
    primaryLight: Color(0xFFFFCCBC),
    primaryLighter: Color(0xFFFFF0E8),
    primaryHex: '#FF8A65',
    background: Color(0xFFFFF8F0),
    visualStyle: AppVisualStyle.cartoon,
  );

  /// 居家暖色 — 书旗向米白 + 暖棕（保留可选，非默认）
  static const communityWarm = AppColorPalette(
    primary: Color(0xFFC8956A),
    primaryDark: Color(0xFF8B7355),
    primaryLight: Color(0xFFE8D4C4),
    primaryLighter: Color(0xFFF5F0E8),
    primaryHex: '#C8956A',
    background: Color(0xFFFAF7F2),
    visualStyle: AppVisualStyle.communityWarm,
  );

  /// 清爽工具风 — 暖灰底 + 白卡，主色仅作点缀（非大面积铺色）
  static const utilityClean = AppColorPalette(
    primary: Color(0xFFFF6633),
    primaryDark: Color(0xFFE85A2B),
    primaryLight: Color(0xFFFFB899),
    primaryLighter: Color(0xFFF5F3F0),
    primaryHex: '#FF6633',
    background: Color(0xFFFAFAF8),
    visualStyle: AppVisualStyle.utilityClean,
  );

  /// 糖果轻点 — 锁定配色见 lwh/code_changed/20260702_vivid_clean_ui_style_spec.md
  static const vividClean = AppColorPalette(
    primary: Color(0xFFFF6B5A),
    primaryDark: Color(0xFFE85A4A),
    primaryLight: Color(0xFFFFB4AA),
    primaryLighter: Color(0xFFF5F3F0),
    primaryHex: '#FF6B5A',
    background: Color(0xFFFAFAF8),
    visualStyle: AppVisualStyle.vividClean,
  );
}
