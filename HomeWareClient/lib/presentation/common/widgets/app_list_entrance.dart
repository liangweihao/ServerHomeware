import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'cartoon_list_entrance.dart';

/// 主题感知列表入场 — 工具风轻 fade / 卡通弹性 slide
class AppListEntrance extends StatelessWidget {
  const AppListEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppColors.isUtilityStyle) {
      return CartoonListEntrance(index: index, child: child);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 180 + (index * 30).clamp(0, 120)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 6),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
