import 'package:flutter/material.dart';
import 'app_visual_style.dart';

/// Material 主题扩展 — 携带视觉风格参数
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    this.visualStyle = AppVisualStyle.cartoon,
  });

  /// 当前视觉风格
  final AppVisualStyle visualStyle;

  @override
  AppThemeExtension copyWith({AppVisualStyle? visualStyle}) {
    return AppThemeExtension(
      visualStyle: visualStyle ?? this.visualStyle,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return t < 0.5 ? this : other;
  }

  /// 从 [BuildContext] 读取扩展
  static AppThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<AppThemeExtension>() ??
        const AppThemeExtension();
  }
}
