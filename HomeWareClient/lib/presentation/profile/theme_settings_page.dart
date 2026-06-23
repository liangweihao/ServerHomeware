import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_color_palette.dart';
import '../../core/theme/app_theme_variant.dart';

/// 主题样式设置页 — 切换应用主色方案
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVariant = ref.watch(appThemeVariantProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('主题样式'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '选择你喜欢的主色风格，立即生效',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          ...AppThemeVariant.values.map(
            (variant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ThemeOptionCard(
                variant: variant,
                selected: currentVariant == variant,
                onTap: () => _selectTheme(ref, variant),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 切换主题并记录日志
  void _selectTheme(WidgetRef ref, AppThemeVariant variant) {
    debugPrint('[ThemeSettings] 用户选择: ${variant.label}');
    ref.read(appThemeVariantProvider.notifier).setVariant(variant);
  }
}

/// 单个主题选项卡片
class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final AppThemeVariant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = variant.palette;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected ? palette.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // 色板预览条
              _PalettePreview(palette: palette),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variant.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      variant.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      palette.primaryHex,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textHint,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: palette.primary, size: 28)
              else
                Icon(Icons.circle_outlined, color: AppColors.textHint, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题色板三色预览
class _PalettePreview extends StatelessWidget {
  const _PalettePreview({required this.palette});

  final AppColorPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _colorDot(palette.primary, 36),
        const SizedBox(height: 4),
        Row(
          children: [
            _colorDot(palette.primaryLight, 16),
            const SizedBox(width: 4),
            _colorDot(palette.primaryLighter, 16),
          ],
        ),
      ],
    );
  }

  Widget _colorDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
    );
  }
}
