import 'app_color_palette.dart';

/// 应用主题样式变体
enum AppThemeVariant {
  /// 默认青松绿
  teal(
    storageKey: 'teal',
    label: '青松绿',
    description: '温和沉稳，适合日常管理',
    palette: AppColorPalettes.teal,
  ),

  /// 创意紫
  creativePurple(
    storageKey: 'creative_purple',
    label: '创意紫',
    description: '创意活力，偏高级质感',
    palette: AppColorPalettes.creativePurple,
  ),

  /// 暖橙活力
  warmOrange(
    storageKey: 'warm_orange',
    label: '暖橙活力',
    description: '温暖亲和，行动感强',
    palette: AppColorPalettes.warmOrange,
  ),

  /// 翡翠清新
  emeraldFresh(
    storageKey: 'emerald_fresh',
    label: '翡翠清新',
    description: '自然清爽，轻量舒适',
    palette: AppColorPalettes.emeraldFresh,
  );

  const AppThemeVariant({
    required this.storageKey,
    required this.label,
    required this.description,
    required this.palette,
  });

  /// SharedPreferences 持久化键值
  final String storageKey;

  /// 展示名称
  final String label;

  /// 简短说明
  final String description;

  /// 对应色板
  final AppColorPalette palette;

  /// 从持久化字符串解析，未知值回退默认
  static AppThemeVariant fromStorage(String? key) {
    if (key == null || key.isEmpty) return AppThemeVariant.teal;
    for (final variant in AppThemeVariant.values) {
      if (variant.storageKey == key) return variant;
    }
    return AppThemeVariant.teal;
  }
}
