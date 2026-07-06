import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/assistant_mascot.dart';

/// 管管头像展示模式
enum GuanguanAvatarMode {
  /// 序列帧 idle（缺资源时降级图标）
  idle,

  /// Material 图标（顶栏等小尺寸）
  icon,
}

/// 管管静态头像 — hello 播完后的 idle 态
class GuanguanMascotAvatar extends StatelessWidget {
  const GuanguanMascotAvatar({
    super.key,
    required this.size,
    this.mode = GuanguanAvatarMode.idle,
  });

  final double size;
  final GuanguanAvatarMode mode;

  @override
  Widget build(BuildContext context) {
    if (mode == GuanguanAvatarMode.icon) {
      return _iconAvatar();
    }

    final idleAsset = AssistantMascot.helloFrames.first;
    return Semantics(
      label: AssistantMascot.name,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          idleAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) {
            debugPrint('[GuanguanMascotAvatar] WARN: idle 资源缺失，降级图标');
            return _iconAvatar();
          },
        ),
      ),
    );
  }

  Widget _iconAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Icon(
        Icons.smart_toy_outlined,
        size: size * 0.52,
        color: AppColors.primary,
      ),
    );
  }
}
