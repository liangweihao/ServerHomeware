import 'app_color_palette.dart';

/// 应用主题 — 仅保留「糖果轻点」
enum AppThemeVariant {
  /// 糖果轻点 — 白底 + 饱和圆角图标点缀
  vividClean(
    storageKey: 'vivid_clean',
    label: '糖果轻点',
    description: '温暖圆润，饱和色块图标，家庭与小店通用',
    palette: AppColorPalettes.vividClean,
  );

  const AppThemeVariant({
    required this.storageKey,
    required this.label,
    required this.description,
    required this.palette,
  });

  /// 唯一默认主题
  static const AppThemeVariant defaultVariant = AppThemeVariant.vividClean;

  final String storageKey;
  final String label;
  final String description;
  final AppColorPalette palette;

  /// 从持久化解析 — 任意旧键均迁移为糖果轻点
  static AppThemeVariant fromStorage(String? key) {
    return vividClean;
  }
}
