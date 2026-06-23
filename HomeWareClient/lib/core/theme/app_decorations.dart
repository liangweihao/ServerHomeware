import 'dart:ui';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'app_visual_style.dart';

/// 主题感知装饰工具 — 卡片、表面等随视觉风格变化
abstract final class AppDecorations {
  /// 新拟态高光阴影色
  static const neumorphHighlight = Color(0xFFFFFFFF);

  /// 新拟态暗部阴影色
  static const neumorphShadow = Color(0xFFC5CCD6);

  /// 标准卡片圆角
  static BorderRadius get cardRadius => BorderRadius.circular(AppRadius.lg);

  /// 新拟态凸起阴影（左上高光 + 右下暗部）
  static List<BoxShadow> neumorphicRaisedShadows({
    double distance = 6,
    double blur = 12,
    double spread = 0,
  }) {
    return [
      BoxShadow(
        color: neumorphHighlight,
        offset: Offset(-distance, -distance),
        blurRadius: blur,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: neumorphShadow,
        offset: Offset(distance, distance),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  /// 新拟态凹陷阴影（内凹输入框等场景）
  static List<BoxShadow> neumorphicInsetShadows({
    double distance = 4,
    double blur = 8,
  }) {
    return [
      BoxShadow(
        color: neumorphShadow.withValues(alpha: 0.5),
        offset: Offset(distance, distance),
        blurRadius: blur,
      ),
      BoxShadow(
        color: neumorphHighlight.withValues(alpha: 0.8),
        offset: Offset(-distance, -distance),
        blurRadius: blur,
      ),
    ];
  }

  /// 卡片/容器表面装饰
  static BoxDecoration surface({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    final radius = borderRadius ?? cardRadius;
    final style = AppColors.visualStyle;

    switch (style) {
      case AppVisualStyle.glassmorphism:
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: radius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.38),
            width: 1,
          ),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
        );
      case AppVisualStyle.gradientBold:
        return BoxDecoration(
          color: Colors.white.withValues(alpha: 0.93),
          borderRadius: radius,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
        );
      case AppVisualStyle.neumorphism:
        return BoxDecoration(
          color: AppColors.background,
          borderRadius: radius,
          boxShadow: boxShadow ?? neumorphicRaisedShadows(),
        );
      case AppVisualStyle.standard:
        return BoxDecoration(
          color: AppColors.white,
          borderRadius: radius,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
        );
    }
  }

  /// 页面背景渐变
  static LinearGradient? pageGradient() {
    final colors = AppColors.pageGradientColors;
    if (colors == null || colors.length < 2) return null;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  /// 底部导航栏背景色
  static Color bottomNavBackground() {
    switch (AppColors.visualStyle) {
      case AppVisualStyle.glassmorphism:
        return Colors.white.withValues(alpha: 0.18);
      case AppVisualStyle.gradientBold:
        return Colors.white.withValues(alpha: 0.2);
      case AppVisualStyle.neumorphism:
        return AppColors.background;
      case AppVisualStyle.standard:
        return AppColors.white;
    }
  }
}

/// 主题感知表面容器 — 玻璃主题下自动叠加毛玻璃模糊
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
    this.enableBlur = true,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;
  final bool enableBlur;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDecorations.cardRadius;
    final decoration = AppDecorations.surface(
      borderRadius: radius,
      boxShadow: boxShadow,
    );

    final content = Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );

    // 玻璃拟态：BackdropFilter 实现磨砂质感
    if (AppColors.visualStyle == AppVisualStyle.glassmorphism && enableBlur) {
      return ClipRRect(
        borderRadius: radius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: content,
        ),
      );
    }

    return content;
  }
}
