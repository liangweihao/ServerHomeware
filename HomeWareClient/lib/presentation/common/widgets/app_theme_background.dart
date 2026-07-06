import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_decorations.dart';

/// 糖果轻点页面背景 — 暖灰底 + 极淡圆点纹理
class AppThemeBackground extends StatelessWidget {
  const AppThemeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColoredBox(color: AppColors.background),
        Positioned.fill(
          child: CustomPaint(
            painter: CartoonDotGridPainter(
              dotColor: AppColors.primary.withValues(alpha: 0.06),
              spacing: 28,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
