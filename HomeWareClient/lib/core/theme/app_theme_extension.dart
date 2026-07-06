import 'package:flutter/material.dart';
import '../../core/theme/app_visual_style.dart';

/// ThemeData 扩展 — 读取当前视觉风格
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({this.visualStyle = AppVisualStyle.vividClean});

  final AppVisualStyle visualStyle;

  @override
  AppThemeExtension copyWith({AppVisualStyle? visualStyle}) {
    return AppThemeExtension(visualStyle: visualStyle ?? this.visualStyle);
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appThemeExt =>
      Theme.of(this).extension<AppThemeExtension>() ??
      const AppThemeExtension();
}
