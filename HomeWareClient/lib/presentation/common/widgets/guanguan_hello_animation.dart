import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/assistant_mascot.dart';

/// 管管打招呼「你好」序列帧动画 — 4 关键帧，帧 3 重复 2 次模拟挥手
class GuanguanHelloAnimation extends StatefulWidget {
  const GuanguanHelloAnimation({
    super.key,
    this.size = 120,
    this.onComplete,
    this.autoPlay = true,
  });

  final double size;

  /// 播完一次后回调（可切回 idle）
  final VoidCallback? onComplete;

  /// 挂载后自动播放
  final bool autoPlay;

  @override
  State<GuanguanHelloAnimation> createState() => _GuanguanHelloAnimationState();
}

class _GuanguanHelloAnimationState extends State<GuanguanHelloAnimation>
    with SingleTickerProviderStateMixin {
  int _frameIndex = 0;
  Timer? _timer;
  bool _finished = false;
  bool _useFallback = false;
  bool _assetChecked = false;

  AnimationController? _fallbackController;
  Animation<double>? _fallbackScale;

  /// 播放顺序：0→1→2→2→3（帧 3 挥两次）
  List<int> get _playOrder => [0, 1, 2, 2, 3];

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prepareAndStart());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fallbackController?.dispose();
    super.dispose();
  }

  Future<void> _prepareAndStart() async {
    if (!mounted || _finished) return;

    var useFallback = false;
    try {
      await DefaultAssetBundle.of(context)
          .load(AssistantMascot.helloFrames.first);
    } catch (e) {
      debugPrint('[GuanguanHelloAnimation] WARN: 序列帧缺失，使用图标 fallback');
      useFallback = true;
    }

    if (!mounted) return;
    setState(() {
      _useFallback = useFallback;
      _assetChecked = true;
    });

    if (useFallback) {
      _startFallback();
    } else {
      _startFrames();
    }
  }

  void _startFrames() {
    if (_finished || !mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _frameIndex = _playOrder.last);
      _finish();
      return;
    }
    debugPrint('[GuanguanHelloAnimation] INFO: 开始播放你好序列');
    _scheduleNext(afterIndex: -1);
  }

  void _startFallback() {
    if (_finished || !mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _finish();
      return;
    }

    _fallbackController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fallbackScale ??= TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _fallbackController!,
      curve: Curves.easeOut,
    ));

    debugPrint('[GuanguanHelloAnimation] INFO: 开始播放图标 fallback');
    var waves = 0;
    const maxWaves = 2;

    void onWaveStatus(AnimationStatus status) {
      if (status != AnimationStatus.completed || !mounted) return;
      waves++;
      if (waves >= maxWaves) {
        _fallbackController!.removeStatusListener(onWaveStatus);
        _finish();
        return;
      }
      _fallbackController!.forward(from: 0);
    }

    _fallbackController!.addStatusListener(onWaveStatus);
    _fallbackController!.forward(from: 0);
  }

  void _scheduleNext({required int afterIndex}) {
    _timer?.cancel();
    final orderPos = afterIndex + 1;
    if (orderPos >= _playOrder.length) {
      _finish();
      return;
    }

    final nextFrame = _playOrder[orderPos];
    final durationMs = AssistantMascot.helloFrameDurationsMs[
        nextFrame.clamp(0, AssistantMascot.helloFrameDurationsMs.length - 1)];

    _timer = Timer(Duration(milliseconds: durationMs), () {
      if (!mounted) return;
      setState(() => _frameIndex = nextFrame);
      _scheduleNext(afterIndex: orderPos);
    });
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    debugPrint('[GuanguanHelloAnimation] INFO: 你好序列播放完成');
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_assetChecked) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    if (_useFallback) {
      return Semantics(
        label: '${AssistantMascot.name}打招呼',
        child: ScaleTransition(
          scale: _fallbackScale ?? const AlwaysStoppedAnimation(1.0),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size: widget.size * 0.48,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final asset = AssistantMascot.helloFrames[
        _frameIndex.clamp(0, AssistantMascot.helloFrames.length - 1)];

    return Semantics(
      label: '${AssistantMascot.name}打招呼',
      child: Image.asset(
        asset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) {
          debugPrint('[GuanguanHelloAnimation] WARN: 帧加载失败 frame=$_frameIndex');
          return Icon(
            Icons.smart_toy_outlined,
            size: widget.size * 0.6,
            color: AppColors.primary,
          );
        },
      ),
    );
  }
}
