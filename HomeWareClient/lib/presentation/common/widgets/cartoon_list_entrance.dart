import 'package:flutter/material.dart';
import '../../../core/theme/cartoon_motion.dart';

/// 列表项入场 — 错开 slide + fade + 弹性
class CartoonListEntrance extends StatefulWidget {
  const CartoonListEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<CartoonListEntrance> createState() => _CartoonListEntranceState();
}

class _CartoonListEntranceState extends State<CartoonListEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CartoonMotion.emptyEnterDuration,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: CartoonMotion.emptyEnterCurve,
    ));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future<void>.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
