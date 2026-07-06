import 'package:flutter/material.dart';
import 'app_visual_style.dart';

/// 糖果轻点色板
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryLighter,
    required this.primaryHex,
    required this.background,
    this.visualStyle = AppVisualStyle.vividClean,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primaryLighter;
  final String primaryHex;
  final Color background;
  final AppVisualStyle visualStyle;

  Color get info => primary;
  Color get infoLight => primaryLighter;
  bool get isStyledTheme => true;
  bool get usesGradientBackground => false;
}

/// 预设色板
abstract final class AppColorPalettes {
  /// 糖果轻点 — 见 doc/design/candy-light-design-system.md
  static const vividClean = AppColorPalette(
    primary: Color(0xFFFF6B5A),
    primaryDark: Color(0xFFE85A4A),
    primaryLight: Color(0xFFFFB4AA),
    primaryLighter: Color(0xFFFFF0ED),
    primaryHex: '#FF6B5A',
    background: Color(0xFFFAF8F6),
    visualStyle: AppVisualStyle.vividClean,
  );
}
