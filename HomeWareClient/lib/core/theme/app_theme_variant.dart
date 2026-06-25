import 'app_color_palette.dart';

/// 应用主题样式变体 — 当前仅保留卡通轻插画
enum AppThemeVariant {
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

  /// 默认主题
  static const AppThemeVariant defaultVariant = AppThemeVariant.cartoon;

  /// SharedPreferences 持久化键值
  final String storageKey;

  /// 展示名称
  final String label;

  /// 简短说明
  final String description;

  /// 对应色板
  final AppColorPalette palette;

  /// 从持久化字符串解析，未知或已移除的主题回退卡通
  static AppThemeVariant fromStorage(String? key) {
    if (key == null || key.isEmpty) return defaultVariant;
    for (final variant in AppThemeVariant.values) {
      if (variant.storageKey == key) return variant;
    }
    // 旧版主题键（glass / neumorphism 等）已移除，回退卡通
    return defaultVariant;
  }
}
