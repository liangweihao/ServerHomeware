import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'cartoon_decorations.dart';

/// 主题装饰工具 — 卡通贴纸卡片
abstract final class AppDecorations {
  /// 卡通主题装饰辅色（背景气泡）
  static const cartoonAccentMint = Color(0xFF6BCB9A);
  static const cartoonAccentYellow = Color(0xFFFFE082);

  /// 卡片圆角
  static BorderRadius get cardRadius => BorderRadius.circular(AppRadius.xl);

  /// 卡片/容器表面装饰 — 贴纸风格
  static BoxDecoration surface({
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return CartoonDecorations.stickerCard(
      borderRadius: borderRadius ?? cardRadius,
    );
  }

  /// 底部导航栏背景色
  static Color bottomNavBackground() => AppColors.white;
}

/// 贴纸表面容器 — 支持自定义马卡龙底色与阴影层级
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
    this.fillColor,
    this.borderColor,
    this.shadowLevel = CartoonShadowLevel.card,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;
  final Color? fillColor;
  final Color? borderColor;
  /// 阴影层级 — 内层嵌套建议 [CartoonShadowLevel.none]
  final CartoonShadowLevel shadowLevel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDecorations.cardRadius;
    final decoration = CartoonDecorations.stickerCard(
      fillColor: fillColor ?? AppColors.white,
      borderColor: borderColor,
      borderRadius: radius,
      shadowLevel: shadowLevel,
    );

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}
