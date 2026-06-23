/// 应用视觉风格（决定背景、卡片质感等，不仅限于主色）
enum AppVisualStyle {
  /// 标准扁平卡片
  standard,

  /// 玻璃拟态：渐变底 + 半透明毛玻璃卡片
  glassmorphism,

  /// 渐变活力：鲜明渐变底 + 高对比强调
  gradientBold,

  /// 新拟态轻质感：同色系软阴影浮雕
  neumorphism,
}

/// [AppVisualStyle] 便捷判断
extension AppVisualStyleX on AppVisualStyle {
  /// 是否使用渐变页面背景（Scaffold 透明、AppBar 浅色字）
  bool get usesGradientBackground =>
      this == AppVisualStyle.glassmorphism ||
      this == AppVisualStyle.gradientBold;

  /// 是否使用新拟态浮雕表面
  bool get usesNeumorphicSurface => this == AppVisualStyle.neumorphism;
}
