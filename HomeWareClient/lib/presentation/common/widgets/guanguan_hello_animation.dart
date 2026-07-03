import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

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

class _GuanguanHelloAnimationState extends State<GuanguanHelloAnimation> {
  int _frameIndex = 0;
  Timer? _timer;
  bool _finished = false;

  /// 播放顺序：0→1→2→2→3（帧 3 挥两次）
  List<int> get _playOrder => [0, 1, 2, 2, 3];

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _start());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_finished || !mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _frameIndex = _playOrder.last);
      widget.onComplete?.call();
      return;
    }
    debugPrint('[GuanguanHelloAnimation] INFO: 开始播放你好序列');
    _scheduleNext(afterIndex: -1);
  }

  void _scheduleNext({required int afterIndex}) {
    _timer?.cancel();
    final orderPos = afterIndex + 1;
    if (orderPos >= _playOrder.length) {
      _finished = true;
      debugPrint('[GuanguanHelloAnimation] INFO: 你好序列播放完成');
      widget.onComplete?.call();
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

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
