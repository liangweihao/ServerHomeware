import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';

/// 全局页面渐变背景 — 包裹在 MaterialApp.builder 内
class AppThemeBackground extends StatelessWidget {
  const AppThemeBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gradient = AppDecorations.pageGradient();

    if (gradient == null) {
      return ColoredBox(
        color: AppColors.background,
        child: child,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
