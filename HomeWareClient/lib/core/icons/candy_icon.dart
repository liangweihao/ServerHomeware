import 'package:flutter/material.dart';

import 'candy_icons.dart';

/// 全站统一圆润图标 — 替代 [Icon]，自动映射 Material Rounded 变体
class CandyIcon extends StatelessWidget {
  const CandyIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.shadows,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Icon(
      CandyIcons.rounded(icon),
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
      shadows: shadows,
    );
  }
}
