import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';

import '../../../core/constants/app_colors.dart';

/// 管管 P2 — 背包打开微动效（序列帧 `backpack_open` 占位）
class GuanguanBackpackReveal extends StatefulWidget {
  const GuanguanBackpackReveal({
    super.key,
    this.size = 40,
    this.highlight = false,
  });

  final double size;

  /// 成就解锁时高亮
  final bool highlight;

  @override
  State<GuanguanBackpackReveal> createState() => _GuanguanBackpackRevealState();
}

class _GuanguanBackpackRevealState extends State<GuanguanBackpackReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.08), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 55),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _lift = Tween<double>(begin: 6, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) return;
      debugPrint('[GuanguanBackpackReveal] INFO: 播放背包打开动效');
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.highlight
        ? AppColors.successLight
        : AppColors.primary.withValues(alpha: 0.1);
    final fg = widget.highlight ? AppColors.success : AppColors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _lift.value),
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.size * 0.28),
        ),
        child: CandyIcon(
          Icons.backpack_outlined,
          size: widget.size * 0.52,
          color: fg,
        ),
      ),
    );
  }
}
