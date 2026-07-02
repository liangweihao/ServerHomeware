import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_visual_style.dart';
import '../../../core/theme/cartoon_decorations.dart';

/// 全局页面背景 — 卡通装饰 / 工具风灰白底
class AppThemeBackground extends StatelessWidget {
  const AppThemeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppColors.visualStyle == AppVisualStyle.cartoon) {
      return Stack(
        children: [
          ColoredBox(color: AppColors.background),
          Positioned.fill(
            child: CustomPaint(
              painter: CartoonDotGridPainter(
                dotColor: AppColors.primary.withValues(alpha: 0.12),
                spacing: 22,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: CartoonSparklePainter(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            top: 48,
            right: -20,
            child: CartoonCloud(
              color: AppColors.primaryLight.withValues(alpha: 0.55),
              width: 140,
              height: 64,
            ),
          ),
          Positioned(
            top: 220,
            left: -36,
            child: CartoonCloud(
              color: AppColors.primary.withValues(alpha: 0.08),
              width: 110,
              height: 52,
            ),
          ),
          child,
        ],
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: child,
    );
  }
}
