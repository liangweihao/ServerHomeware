import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../common/widgets/guanguan_mascot_avatar.dart';
import 'assistant_chat_theme.dart';

/// 管管思考中 — 糖果轻点风格等待动画（LLM 响应中展示）
class AssistantTypingIndicator extends StatefulWidget {
  const AssistantTypingIndicator({super.key});

  @override
  State<AssistantTypingIndicator> createState() => _AssistantTypingIndicatorState();
}

class _AssistantTypingIndicatorState extends State<AssistantTypingIndicator>
    with TickerProviderStateMixin {
  /// 糖果色跳动圆点 — 珊瑚 / 青绿 / 蜜糖
  static const _dotColors = [
    AppColors.accentCoral,
    AppColors.accentTeal,
    AppColors.accentAmber,
  ];

  /// 轮播提示文案
  static const _statusHints = [
    '管管正在想…',
    '翻翻家里库存…',
    '马上回复你～',
  ];

  late final AnimationController _dotController;
  late final AnimationController _mascotController;
  late final Animation<double> _mascotBob;
  Timer? _hintTimer;
  int _hintIndex = 0;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _mascotBob = Tween<double>(begin: 0, end: -3).animate(
      CurvedAnimation(parent: _mascotController, curve: Curves.easeInOut),
    );

    _hintTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() => _hintIndex = (_hintIndex + 1) % _statusHints.length);
    });

    debugPrint('[AssistantTypingIndicator] INFO: 展示思考动画');
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _dotController.dispose();
    _mascotController.dispose();
    super.dispose();
  }

  /// 单个糖果圆点的纵向跳动偏移
  double _dotOffset(int index) {
    final t = (_dotController.value + index * 0.22) % 1.0;
    return math.sin(t * math.pi * 2) * 3.5;
  }

  @override
  Widget build(BuildContext context) {
    final disableAnim = MediaQuery.disableAnimationsOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AssistantChatTheme.turnSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _mascotBob,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, disableAnim ? 0 : _mascotBob.value),
                child: child,
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(top: 2),
              child: GuanguanMascotAvatar(size: AssistantChatTheme.mascotSize),
            ),
          ),
          const SizedBox(width: AssistantChatTheme.avatarGap),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 13, 16, 12),
              decoration: AssistantChatTheme.assistantBubbleDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _dotController,
                    builder: (context, _) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_dotColors.length, (i) {
                          final y = disableAnim ? 0.0 : _dotOffset(i);
                          return Padding(
                            padding: EdgeInsets.only(right: i < 2 ? 7 : 0),
                            child: Transform.translate(
                              offset: Offset(0, y),
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: _dotColors[i],
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 9),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Text(
                      _statusHints[_hintIndex],
                      key: ValueKey<int>(_hintIndex),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
