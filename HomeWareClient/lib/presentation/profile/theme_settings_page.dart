import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';
import '../../core/icons/app_icon.dart';
import '../../core/icons/candy_icons.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/warm_scaffold.dart';

/// 糖果轻点设计规范预览（只读）
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  static const _accents = [
    ('珊瑚主色', AppColors.accentCoral),
    ('青绿', AppColors.accentTeal),
    ('天蓝', AppColors.accentSky),
    ('紫藤', AppColors.accentViolet),
    ('蜜糖', AppColors.accentAmber),
    ('玫瑰', AppColors.accentRose),
  ];

  @override
  Widget build(BuildContext context) {
    return WarmScaffold(
      title: '视觉规范',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('糖果轻点', style: AppTypography.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  '全 App 统一：暖灰白底、Nunito 圆体、饱和圆角图标底、大圆角卡片。',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('主色与点缀', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _accents.map((item) {
                    final (name, color) = item;
                    return Column(
                      children: [
                        AppIcon.feature(
                          icon: CandyIcons.inventory,
                          accent: color,
                          wellSize: 48,
                        ),
                        const SizedBox(height: 4),
                        Text(name, style: AppTypography.caption),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('字体层级', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Text('大标题', style: AppTypography.headlineLarge),
                Text('页面标题', style: AppTypography.titleLarge),
                Text('正文 16', style: AppTypography.bodyLarge),
                Text('辅助 14', style: AppTypography.bodyMedium),
                Text('标签 11', style: AppTypography.labelSmall),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('圆角', style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RadiusChip('md 14', AppRadius.md),
                    const SizedBox(width: 8),
                    _RadiusChip('lg 18', AppRadius.lg),
                    const SizedBox(width: 8),
                    _RadiusChip('xl 24', AppRadius.xl),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadiusChip extends StatelessWidget {
  const _RadiusChip(this.label, this.radius);

  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(label, style: AppTypography.labelSmall),
    );
  }
}
