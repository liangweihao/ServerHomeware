import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'cartoon_pressable.dart';

/// AppBar 图标按钮 — 圆形贴纸底（仅描边，无内层阴影）
class CartoonAppBarIcon extends StatelessWidget {
  const CartoonAppBarIcon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    Widget child = CartoonPressable(
      onTap: onPressed,
      scale: 0.88,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryDark.withValues(alpha: 0.85),
            width: 2.5,
          ),
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryDark),
      ),
    );

    if (badge != null) {
      child = Badge(child: child);
    }

    if (tooltip != null) {
      child = Tooltip(message: tooltip!, child: child);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: child,
    );
  }
}
