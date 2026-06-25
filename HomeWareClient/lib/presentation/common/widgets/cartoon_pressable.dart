import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/cartoon_motion.dart';

/// 卡通按压缩放反馈
class CartoonPressable extends StatefulWidget {
  const CartoonPressable({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.scale = CartoonMotion.pressScale,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double scale;

  @override
  State<CartoonPressable> createState() => _CartoonPressableState();
}

class _CartoonPressableState extends State<CartoonPressable> {
  bool _pressed = false;

  void _handleTap() {
    if (!widget.enabled) return;
    debugPrint('[CartoonPressable] onTap');
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: _pressed
            ? CartoonMotion.pressDownDuration
            : CartoonMotion.pressUpDuration,
        curve: _pressed
            ? CartoonMotion.pressDownCurve
            : CartoonMotion.pressUpCurve,
        child: widget.child,
      ),
    );
  }
}
