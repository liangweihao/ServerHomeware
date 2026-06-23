import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_color_palette.dart';
import '../../core/theme/app_theme_variant.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_visual_style.dart';

/// 主题样式设置页 — 切换应用主色与视觉风格
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVariant = ref.watch(appThemeVariantProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: const Text('主题样式'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '选择你喜欢的主色风格，立即生效',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.visualStyle.usesGradientBackground
                      ? AppColors.white.withValues(alpha: 0.85)
                      : AppColors.textSecondary,
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
    final isGradient = palette.usesGradientBackground;
    final isNeumorph = palette.visualStyle == AppVisualStyle.neumorphism;
    final isEffect = palette.isStyledTheme;

    return Material(
      color: isGradient
          ? Colors.white.withValues(alpha: 0.15)
          : (isNeumorph ? palette.background : AppColors.white),
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
            boxShadow: isNeumorph
                ? AppDecorations.neumorphicRaisedShadows(distance: 4, blur: 8)
                : null,
          ),
          child: Row(
            children: [
              _ThemePreview(palette: palette),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          variant.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isGradient
                                        ? AppColors.white
                                        : AppColors.textPrimary,
                                  ),
                        ),
                        if (isEffect) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '特效',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      variant.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isGradient
                                ? AppColors.white.withValues(alpha: 0.75)
                                : AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      palette.primaryHex,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isGradient
                                ? AppColors.white.withValues(alpha: 0.6)
                                : AppColors.textHint,
                            fontFamily: 'monospace',
                          ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: palette.primary, size: 28)
              else
                Icon(
                  Icons.circle_outlined,
                  color: isGradient
                      ? AppColors.white.withValues(alpha: 0.5)
                      : AppColors.textHint,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 主题预览：渐变主题显示色带，标准主题显示色点
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.palette});

  final AppColorPalette palette;

  @override
  Widget build(BuildContext context) {
    // 新拟态：展示浮雕质感预览
    if (palette.visualStyle == AppVisualStyle.neumorphism) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppDecorations.neumorphicRaisedShadows(
            distance: 3,
            blur: 6,
          ),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: palette.primary,
              shape: BoxShape.circle,
              boxShadow: AppDecorations.neumorphicRaisedShadows(
                distance: 2,
                blur: 4,
              ),
            ),
          ),
        ),
      );
    }

    if (palette.gradientColors != null && palette.gradientColors!.length >= 2) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette.gradientColors!,
          ),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.4),
          ),
        ),
      );
    }

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
