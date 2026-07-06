import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/assistant_mascot.dart';

/// 管管处理闭环庆祝 — 轻量 SnackBar + 图标微弹跳
class GuanguanCelebrationSnackBar {
  GuanguanCelebrationSnackBar._();

  /// 展示管管语气庆祝反馈（替代纯系统 Toast）
  static void show(BuildContext context, {required String message}) {
    debugPrint('[GuanguanCelebrationSnackBar] INFO: $message');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor: AppColors.primaryDark,
          content: _CelebrationContent(message: message),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}

class _CelebrationContent extends StatefulWidget {
  const _CelebrationContent({required this.message});

  final String message;

  @override
  State<_CelebrationContent> createState() => _CelebrationContentState();
}

class _CelebrationContentState extends State<_CelebrationContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  /// 防止 didChangeDependencies 重复触发时多次启动动画
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery 属于 InheritedWidget，必须在 initState 之后访问
    if (_animationStarted || MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    _animationStarted = true;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTransition(
          scale: _scale,
          child: const Icon(
            Icons.emoji_emotions_outlined,
            color: AppColors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            widget.message,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),
        Text(
          AssistantMascot.name,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
