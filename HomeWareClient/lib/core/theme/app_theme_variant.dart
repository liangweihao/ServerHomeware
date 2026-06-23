import 'app_color_palette.dart';

/// 应用主题样式变体（仅保留三种特效主题）
enum AppThemeVariant {
  /// 玻璃拟态
  glassmorphism(
    storageKey: 'glassmorphism',
    label: '玻璃拟态',
    description: '磨砂玻璃质感，现代高级',
    palette: AppColorPalettes.glassmorphism,
  ),

  /// 渐变活力
  gradientBold(
    storageKey: 'gradient_bold',
    label: '渐变活力',
    description: '鲜明渐变，年轻有活力',
    palette: AppColorPalettes.gradientBold,
  ),

  /// 新拟态轻质感（默认）
  neumorphism(
    storageKey: 'neumorphism',
    label: '新拟态轻质感',
    description: '软阴影浮雕，触感温润',
    palette: AppColorPalettes.neumorphism,
  );

  const AppThemeVariant({
    required this.storageKey,
    required this.label,
    required this.description,
    required this.palette,
  });

  /// 默认主题
  static const AppThemeVariant defaultVariant = AppThemeVariant.neumorphism;

  /// SharedPreferences 持久化键值
  final String storageKey;

  /// 展示名称
  final String label;

  /// 简短说明
  final String description;

  /// 对应色板
  final AppColorPalette palette;

  /// 从持久化字符串解析，未知或已移除的主题回退默认
  static AppThemeVariant fromStorage(String? key) {
    if (key == null || key.isEmpty) return defaultVariant;
    for (final variant in AppThemeVariant.values) {
      if (variant.storageKey == key) return variant;
    }
    // 旧版主题键（teal / creative_purple 等）已移除，回退默认
    return defaultVariant;
  }
}
