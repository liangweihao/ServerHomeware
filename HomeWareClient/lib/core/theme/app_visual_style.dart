/// 应用视觉风格 — 当前仅保留卡通轻插画
enum AppVisualStyle {
  /// 卡通轻插画：暖色底 + 大圆角描边卡片
  cartoon,
}

/// [AppVisualStyle] 便捷判断
extension AppVisualStyleX on AppVisualStyle {
  /// 是否使用渐变页面背景
  bool get usesGradientBackground => false;

  /// 是否使用新拟态浮雕表面
  bool get usesNeumorphicSurface => false;

  /// 是否使用卡通描边卡片
  bool get usesCartoonDecor => true;

  /// 是否使用自定义底栏
  bool get usesCustomBottomNav => true;
}
