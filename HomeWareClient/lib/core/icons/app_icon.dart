import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'candy_icons.dart';

/// 糖果轻点统一图标 — 饱和圆角底 + 白标 / 圆润 Material 图标
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    this.icon,
    this.asset,
    this.color,
    this.background,
    this.size = 22,
    this.wellSize = 44,
    this.showWell = true,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final String? asset;
  final Color? color;
  final Color? background;
  final double size;
  final double wellSize;
  final bool showWell;

  /// 功能色块图标（个人中心宫格等）
  factory AppIcon.feature({
    required IconData icon,
    required Color accent,
    double wellSize = 44,
    double iconSize = 22,
  }) {
    final (bg, fg) = AppColors.iconWellFor(accent);
    return AppIcon(
      icon: CandyIcons.rounded(icon),
      color: fg,
      background: bg,
      size: iconSize,
      wellSize: wellSize,
    );
  }

  /// SVG 资源图标（底栏等）
  factory AppIcon.svg({
    required String asset,
    Color? color,
    double size = 24,
    bool showWell = false,
  }) {
    return AppIcon(
      asset: asset,
      color: color,
      size: size,
      showWell: showWell,
    );
  }

  @override
  Widget build(BuildContext context) {
    final glyph = _buildGlyph();

    if (!showWell) return glyph;

    return Container(
      width: wellSize,
      height: wellSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: glyph,
    );
  }

  Widget _buildGlyph() {
    final tint = color ?? AppColors.textSecondary;

    if (asset != null) {
      return SvgPicture.asset(
        asset!,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      );
    }

    return Icon(
      CandyIcons.rounded(icon!),
      size: size,
      color: tint,
    );
  }
}
