import 'app_color_palette.dart';

/// 应用主题样式变体
enum AppThemeVariant {
  /// 清爽工具风（点评橙 + 闲鱼灰白，默认）
  utilityClean(
    storageKey: 'utility_clean',
    label: '清爽工具',
    description: '点评式列表橙，闲鱼式灰白底',
    palette: AppColorPalettes.utilityClean,
  ),

  /// 糖果轻点 — 鲜活干净预览（白底多彩点缀）
  vividClean(
    storageKey: 'vivid_clean',
    label: '糖果轻点',
    description: '白底饱和图标与标签，鲜艳不厚重',
    palette: AppColorPalettes.vividClean,
  ),

  /// 居家暖色 — 书旗向（可选）
  communityWarm(
    storageKey: 'community_warm',
    label: '居家暖色',
    description: '米白极简，温和清晰',
    palette: AppColorPalettes.communityWarm,
  ),

  /// 卡通轻插画
  cartoon(
    storageKey: 'cartoon',
    label: '卡通轻插画',
    description: '温暖圆润，家庭友好',
    palette: AppColorPalettes.cartoon,
  );

  const AppThemeVariant({
    required this.storageKey,
    required this.label,
    required this.description,
    required this.palette,
  });

  /// 默认主题 — 清爽工具风
  static const AppThemeVariant defaultVariant = AppThemeVariant.utilityClean;

  /// SharedPreferences 持久化键值
  final String storageKey;

  /// 展示名称
  final String label;

  /// 简短说明
  final String description;

  /// 对应色板
  final AppColorPalette palette;

  /// 从持久化字符串解析，未知键回退 [defaultVariant]
  static AppThemeVariant fromStorage(String? key) {
    if (key == null || key.isEmpty) return defaultVariant;
    for (final variant in AppThemeVariant.values) {
      if (variant.storageKey == key) return variant;
    }
    return defaultVariant;
  }
}
