import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';

/// 卡通 UI 工具
abstract final class CartoonUi {
  /// 带 emoji 的页面标题
  static String pageTitle(String title, {String? emoji}) {
    if (emoji == null) return title;
    return '$emoji $title';
  }
}

/// 贴纸风格小标签 — 列表内数量/状态/分类等
class CartoonStickerBadge extends StatelessWidget {
  const CartoonStickerBadge({
    super.key,
    required this.label,
    required this.accentColor,
    this.fillColor,
    this.emoji,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.compact = false,
  });

  final String label;
  final Color accentColor;
  final Color? fillColor;
  final String? emoji;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  /// 紧凑模式 — 元信息 Chip 无阴影，避免嵌套叠影
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final borderW = compact ? 2.0 : 2.5;
    final shadowLevel = compact
        ? CartoonShadowLevel.none
        : CartoonShadowLevel.subtle;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fillColor ?? accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(compact ? 9 : 11),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.72),
          width: borderW,
        ),
        boxShadow: CartoonDecorations.shadows(shadowLevel),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: TextStyle(fontSize: fontSize + 1, height: 1)),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: accentColor,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

/// 列表卡片内层 — 白底内容区，仅描边无阴影（阴影由外层卡片承担）
class CartoonInnerPanel extends StatelessWidget {
  const CartoonInnerPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final border = borderColor ?? AppColors.primaryLight;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 2),
      ),
      child: child,
    );
  }
}

/// 卡通区块卡片 — 统计/设置等分组容器
class CartoonSectionCard extends StatelessWidget {
  const CartoonSectionCard({
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
    final (fill, border) = CartoonPalette.pairAt(colorIndex);
    return Container(
      margin: margin,
      child: AppSurface(
        fillColor: fill,
        borderColor: border,
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
