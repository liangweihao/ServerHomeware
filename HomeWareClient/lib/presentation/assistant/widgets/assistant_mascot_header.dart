import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/assistant_mascot.dart';
import '../../../core/services/guanguan_hello_prefs.dart';
import '../../common/widgets/guanguan_hello_animation.dart';
import '../../common/widgets/guanguan_mascot_avatar.dart';

/// 问管管页顶栏 — 每日首次 hello 序列帧，之后静态 idle
class AssistantMascotHeader extends StatefulWidget {
  const AssistantMascotHeader({super.key});

  @override
  State<AssistantMascotHeader> createState() => _AssistantMascotHeaderState();
}

class _AssistantMascotHeaderState extends State<AssistantMascotHeader> {
  bool _loading = true;
  bool _playHello = false;
  bool _helloFinished = false;

  @override
  void initState() {
    super.initState();
    _resolveHelloState();
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
    final mascotSize = showLargeHello ? 96.0 : 44.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(16, showLargeHello ? 8 : 4, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.homeDivider)),
      ),
      child: Row(
        children: [
          if (showLargeHello)
            GuanguanHelloAnimation(
              size: mascotSize,
              onComplete: _onHelloComplete,
            )
          else
            GuanguanMascotAvatar(size: mascotSize, mode: GuanguanAvatarMode.idle),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AssistantMascot.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  showLargeHello ? '你好呀～' : '随时问我库存和提醒',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.9),
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
