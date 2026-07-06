/// 应用视觉风格 — 仅糖果轻点
enum AppVisualStyle {
  /// 糖果轻点：暖灰白底 + 饱和圆角图标 + 大圆角卡片
  vividClean,
}

extension AppVisualStyleX on AppVisualStyle {
  bool get usesGradientBackground => false;
  bool get usesNeumorphicSurface => false;
  bool get usesCartoonDecor => false;
  bool get usesCustomBottomNav => true;
  bool get usesUtilityDecor => true;
}
