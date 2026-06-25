import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/cartoon_decorations.dart';
import 'cartoon_pressable.dart';

/// 卡通 FAB — 圆角矩形 + 贴纸阴影 + 弹性按压
class CartoonFloatingActionButton extends StatelessWidget {
  const CartoonFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final fab = CartoonPressable(
      onTap: onPressed,
      enabled: onPressed != null,
      child: Material(
        color: AppColors.primary,
        elevation: 0,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primaryDark.withValues(alpha: 0.88),
              width: CartoonDecorations.borderWidth,
            ),
            boxShadow: CartoonDecorations.shadows(CartoonShadowLevel.floating),
          ),
          child: Center(child: child),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: fab);
    }
    return fab;
  }
}
