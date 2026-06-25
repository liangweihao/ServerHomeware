import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/cartoon_motion.dart';

/// 卡通吉祥物 — 首页问候条等处展示，带轻微 idle 弹跳
class CartoonMascot extends StatefulWidget {
  const CartoonMascot({
    super.key,
    this.size = 72,
    this.assetPath = 'assets/illustrations/mascot_box.svg',
  });

  final double size;
  final String assetPath;

  @override
  State<CartoonMascot> createState() => _CartoonMascotState();
}

class _CartoonMascotState extends State<CartoonMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _bobController;
  late Animation<double> _bobAnim;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bobAnim = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bobAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnim.value),
          child: child,
        );
      },
      child: SvgPicture.asset(
        widget.assetPath,
        width: widget.size,
        height: widget.size,
        semanticsLabel: '卡通吉祥物',
      ),
    );
  }
}
