import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';

/// 主题感知卡片 — 工具风白底轻阴影 / 卡通 AppSurface
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
    this.selected = false,
    this.colorIndex = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final bool selected;

  /// 卡通风配色索引
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? const EdgeInsets.all(16);

    if (AppColors.isUtilityStyle) {
      final border = borderColor ??
          (selected ? AppColors.primary : AppColors.homeDivider);

      final content = Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Padding(padding: pad, child: child),
      );

      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          elevation: 0,
          shadowColor: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: content,
                )
              : content,
        ),
      );
    }

    final (fill, border) = CartoonPalette.pairAt(colorIndex);
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: AppSurface(
        padding: pad,
        fillColor: selected ? AppColors.primaryLighter : fill,
        borderColor: selected ? AppColors.primaryDark : border,
        shadowLevel: CartoonShadowLevel.card,
        child: child,
      ),
    );
  }
}

/// 卡通主题分组卡片 — 统计等区块（仅非工具风）
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    this.padding,
    this.colorIndex = 0,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final int colorIndex;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isUtilityStyle) {
      return AppCard(
        margin: margin,
        padding: padding,
        colorIndex: colorIndex,
        child: child,
      );
    }

    return AppCard(
      margin: margin,
      padding: padding,
      colorIndex: colorIndex,
      child: child,
    );
  }
}
