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

/// 预设色板 — 仅卡通主题
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
}
