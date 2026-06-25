import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/cartoon_copy.dart';
import '../../../core/theme/cartoon_motion.dart';

/// 卡通空状态插画 — 按 [CartoonEmptyKind] 加载 SVG
class CartoonEmptyIllustration extends StatefulWidget {
  const CartoonEmptyIllustration({
    super.key,
    required this.kind,
    this.size = 120,
  });

  final CartoonEmptyKind kind;
  final double size;

  static String assetPath(CartoonEmptyKind kind) {
    return switch (kind) {
      CartoonEmptyKind.items => 'assets/illustrations/empty_items.svg',
      CartoonEmptyKind.search => 'assets/illustrations/empty_search.svg',
      CartoonEmptyKind.alerts => 'assets/illustrations/empty_alerts.svg',
      CartoonEmptyKind.family => 'assets/illustrations/empty_family.svg',
      CartoonEmptyKind.error => 'assets/illustrations/empty_error.svg',
    };
  }

  @override
  State<CartoonEmptyIllustration> createState() =>
      _CartoonEmptyIllustrationState();
}

class _CartoonEmptyIllustrationState extends State<CartoonEmptyIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _enterController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
      vsync: this,
      duration: CartoonMotion.emptyEnterDuration,
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: CartoonMotion.emptyEnterCurve,
      ),
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: SvgPicture.asset(
        CartoonEmptyIllustration.assetPath(widget.kind),
        width: widget.size,
        height: widget.size,
        semanticsLabel: '空状态插画',
      ),
    );
  }
}
