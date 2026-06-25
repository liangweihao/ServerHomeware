import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/cartoon_decorations.dart';
import 'cartoon_bottom_nav.dart';
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

/// 主 Tab 页 FAB 定位 — 抬高以避开 [CartoonBottomNav]
class CartoonMainTabFabLocation extends FloatingActionButtonLocation {
  const CartoonMainTabFabLocation(this.bottomInset);

  final double bottomInset;

  /// 根据当前上下文计算底栏占用高度
  factory CartoonMainTabFabLocation.of(BuildContext context) {
    return CartoonMainTabFabLocation(CartoonBottomNav.totalHeight(context));
  }

  static const _margin = 16.0;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final scaffoldSize = scaffoldGeometry.scaffoldSize;
    return Offset(
      scaffoldSize.width - fabSize.width - _margin,
      scaffoldSize.height - fabSize.height - _margin - bottomInset,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CartoonMainTabFabLocation &&
        other.bottomInset == bottomInset;
  }

  @override
  int get hashCode => bottomInset.hashCode;
}
