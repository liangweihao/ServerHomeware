import 'package:flutter/material.dart';
import 'app_visual_style.dart';

/// Material 主题扩展 — 携带渐变背景等视觉风格参数
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.visualStyle,
    this.gradientColors,
    this.useLightAppBarForeground = false,
  });

  /// 当前视觉风格
  final AppVisualStyle visualStyle;

  /// 页面渐变背景色（为空则使用纯色背景）
  final List<Color>? gradientColors;

  /// AppBar 是否使用浅色前景（渐变/玻璃主题下标题与图标为白色）
  final bool useLightAppBarForeground;

  /// 是否使用渐变页面背景
  bool get hasGradientBackground =>
      gradientColors != null && gradientColors!.length >= 2;

  @override
  AppThemeExtension copyWith({
    AppVisualStyle? visualStyle,
    List<Color>? gradientColors,
    bool? useLightAppBarForeground,
  }) {
    return AppThemeExtension(
      visualStyle: visualStyle ?? this.visualStyle,
      gradientColors: gradientColors ?? this.gradientColors,
      useLightAppBarForeground:
          useLightAppBarForeground ?? this.useLightAppBarForeground,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return t < 0.5 ? this : other;
  }

  /// 从 [BuildContext] 读取扩展，无则回退标准风格
  static AppThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>() ??
        const AppThemeExtension(visualStyle: AppVisualStyle.standard);
  }
}
