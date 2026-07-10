import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/assistant_mascot.dart';
import '../../../core/services/guanguan_hello_prefs.dart';
import '../../common/widgets/guanguan_hello_animation.dart';
import '../../common/widgets/guanguan_mascot_avatar.dart';

/// 问管管页顶栏 — 暖色渐变 + 每日 hello；思考时联动状态文案
class AssistantMascotHeader extends StatefulWidget {
  const AssistantMascotHeader({super.key, this.isThinking = false});

  /// LLM 响应中 — 展示思考态副标题与轻微呼吸动画
  final bool isThinking;

  @override
  State<AssistantMascotHeader> createState() => _AssistantMascotHeaderState();
}

class _AssistantMascotHeaderState extends State<AssistantMascotHeader>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _playHello = false;
  bool _helloFinished = false;
  AnimationController? _thinkPulse;

  @override
  void initState() {
    super.initState();
    _resolveHelloState();
    _thinkPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didUpdateWidget(AssistantMascotHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncThinkPulse();
  }

  void _syncThinkPulse() {
    if (widget.isThinking && !(_thinkPulse?.isAnimating ?? false)) {
      _thinkPulse?.repeat(reverse: true);
      debugPrint('[AssistantMascotHeader] INFO: 进入思考态');
    } else if (!widget.isThinking && (_thinkPulse?.isAnimating ?? false)) {
      _thinkPulse?.stop();
      _thinkPulse?.value = 0;
    }
  }

  @override
  void dispose() {
    _thinkPulse?.dispose();
    super.dispose();
  }

  Future<void> _resolveHelloState() async {
    final shouldPlay = await GuanguanHelloPrefs.shouldPlayHelloToday();
    if (!mounted) return;
    setState(() {
      _playHello = shouldPlay;
      _helloFinished = !shouldPlay;
      _loading = false;
    });
    if (shouldPlay) {
      debugPrint('[AssistantMascotHeader] INFO: 今日首次进入，播放 hello');
    }
    _syncThinkPulse();
  }

  Future<void> _onHelloComplete() async {
    await GuanguanHelloPrefs.markHelloShownToday();
    if (!mounted) return;
    setState(() => _helloFinished = true);
    debugPrint('[AssistantMascotHeader] INFO: hello 完成，切 idle');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 72);
    }

    final showLargeHello = _playHello && !_helloFinished;
    final mascotSize = showLargeHello ? 88.0 : 46.0;
    final subtitle = widget.isThinking
        ? '正在帮你查…'
        : (showLargeHello ? '你好呀，有什么想问的～' : '库存、位置、提醒都可以问我');

    Widget mascot;
    if (showLargeHello) {
      mascot = GuanguanHelloAnimation(
        size: mascotSize,
        onComplete: _onHelloComplete,
      );
    } else if (widget.isThinking && _thinkPulse != null) {
      mascot = ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.05).animate(
          CurvedAnimation(parent: _thinkPulse!, curve: Curves.easeInOut),
        ),
        child: GuanguanMascotAvatar(size: mascotSize, mode: GuanguanAvatarMode.idle),
      );
    } else {
      mascot = GuanguanMascotAvatar(size: mascotSize, mode: GuanguanAvatarMode.idle);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(16, showLargeHello ? 10 : 6, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLighter,
            AppColors.white,
            AppColors.gray50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCoral.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          mascot,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AssistantMascot.name,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    subtitle,
                    key: ValueKey<String>(subtitle),
                    style: AppTypography.bodySmall.copyWith(
                      color: widget.isThinking
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          widget.isThinking ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
