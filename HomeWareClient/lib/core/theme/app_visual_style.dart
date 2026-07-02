/// 应用视觉风格
enum AppVisualStyle {
  /// 卡通轻插画：暖色底 + 大圆角描边卡片
  cartoon,

  /// 居家暖色（书旗向，已非默认）
  communityWarm,

  /// 清爽工具风：点评橙 + 闲鱼灰白底 + 轻投影卡片
  utilityClean,

  /// 糖果轻点：白底 + 小面积饱和点缀（鲜活干净预览）
  vividClean,
}

/// [AppVisualStyle] 便捷判断
extension AppVisualStyleX on AppVisualStyle {
  /// 是否使用渐变页面背景
  bool get usesGradientBackground => false;

  /// 是否使用新拟态浮雕表面
  bool get usesNeumorphicSurface => false;

  /// 是否使用卡通描边卡片
  bool get usesCartoonDecor => this == AppVisualStyle.cartoon;

  /// 是否使用自定义底栏
  bool get usesCustomBottomNav => this == AppVisualStyle.cartoon;

  /// 是否使用工具风（点评/闲鱼向）— 细边框、轻阴影、中性字色
  bool get usesUtilityDecor =>
      this == AppVisualStyle.utilityClean ||
      this == AppVisualStyle.communityWarm ||
      this == AppVisualStyle.vividClean;
}
