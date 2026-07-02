import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/auth_service.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/tag_chip.dart';
import 'profile_health_ring.dart';
import 'profile_inventory_health.dart';

/// 个人中心身份头图 — 点阵纹理 + 时段问候 + 健康圆环
class ProfileIdentityHeader extends StatelessWidget {
  const ProfileIdentityHeader({
    super.key,
    required this.nickname,
    required this.phone,
    this.familyName,
    this.roleLabel,
    this.health,
    this.onEdit,
    this.onHealthTap,
    this.compact = false,
  });

  final String nickname;
  final String phone;
  final String? familyName;
  final String? roleLabel;
  final ProfileInventoryHealth? health;
  final VoidCallback? onEdit;
  final VoidCallback? onHealthTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final avatarIndex = AuthService.getAvatarColorIndex(phone);
    final colors = AuthService.getAvatarColors(avatarIndex);
    final displayChar = _displayChar(nickname, phone);
    final avatarSize = compact ? 52.0 : 60.0;
    final greeting = profileTimeGreeting();
    final theme = health;
    final utility = AppColors.isUtilityStyle;
    final gradientColors = theme?.headerGradientColors ??
        (utility
            ? [AppColors.white, AppColors.gray50]
            : [
                AppColors.primary.withValues(alpha: 0.14),
                AppColors.white,
                AppColors.accentHighlight.withValues(alpha: 0.12),
              ]);
    final accent = theme?.headerAccent ??
        (utility ? Colors.transparent : AppColors.primary.withValues(alpha: 0.08));
    final greetingColor =
        theme?.greetingColor ?? (utility ? AppColors.textSecondary : AppColors.primary);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Stack(
          children: [
            if (!utility)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                ),
              ),
            if (!utility)
              Positioned.fill(
                child: CustomPaint(
                  painter: _DotPatternPainter(
                    dotColor: theme?.color.withValues(alpha: 0.08) ??
                        AppColors.primary.withValues(alpha: 0.06),
                  ),
                ),
              ),
            // 工具风：仅保留极淡底，无渐变贴纸感
            if (utility)
              Positioned.fill(
                child: ColoredBox(color: AppColors.white),
              ),
            if (!utility) ...[
              Positioned(
                top: 12,
                right: health != null ? 88 : 16,
                child: _DecorIcon(
                  icon: Icons.kitchen_outlined,
                  color: (theme?.color ?? AppColors.primary).withValues(alpha: 0.14),
                  size: 28,
                  angle: -0.15,
                ),
              ),
              Positioned(
                bottom: 18,
                right: health != null ? 100 : 48,
                child: _DecorIcon(
                  icon: Icons.inventory_2_outlined,
                  color: (theme?.color ?? AppColors.warning).withValues(alpha: 0.12),
                  size: 32,
                  angle: 0.12,
                ),
              ),
              Positioned(
                top: -24,
                right: -16,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 550),
                  curve: Curves.easeInOut,
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                compact ? 14 : 18,
                16,
                compact ? 14 : 18,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'user_avatar',
                    child: _AvatarRing(
                      size: avatarSize,
                      colors: colors,
                      displayChar: displayChar,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                          style: TextStyle(
                            fontSize: 12,
                            color: greetingColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                          child: Text(greeting),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nickname.isNotEmpty ? nickname : '用户',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: compact ? 17 : 20,
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (familyName != null && familyName!.isNotEmpty)
                              TagChip(
                                label: familyName!,
                                color: AppColors.textPrimary,
                                background: AppColors.gray100,
                              ),
                            if (roleLabel != null && roleLabel!.isNotEmpty)
                              TagChip(
                                label: roleLabel!,
                                color: AppColors.textSecondary,
                                background: AppColors.gray100,
                              ),
                          ],
                        ),
                        if (!compact) ...[
                          const SizedBox(height: 6),
                          Text(
                            _maskPhone(phone),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (health != null)
                    ProfileHealthRing(
                      health: health!,
                      size: compact ? 58 : 68,
                      onTap: onHealthTap,
                    ),
                ],
              ),
            ),
            if (onEdit != null)
              Positioned(
                top: 10,
                right: 10,
                child: _EditChip(onTap: onEdit!),
              ),
          ],
        ),
      ),
    );
  }

  String _displayChar(String nickname, String phone) {
    if (nickname.isNotEmpty) return nickname[0].toUpperCase();
    if (phone.length >= 4) return phone.substring(phone.length - 4);
    return '?';
  }

  String _maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
}

class _EditChip extends StatelessWidget {
  const _EditChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () {
          debugPrint('[ProfileIdentityHeader] INFO: 编辑资料');
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '编辑',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorIcon extends StatelessWidget {
  const _DecorIcon({
    required this.icon,
    required this.color,
    required this.size,
    this.angle = 0,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Icon(icon, size: size, color: color),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({
    required this.size,
    required this.colors,
    required this.displayChar,
  });

  final double size;
  final List<int> colors;
  final String displayChar;

  @override
  Widget build(BuildContext context) {
    final utility = AppColors.isUtilityStyle;

    if (utility) {
      return Container(
        width: size + 4,
        height: size + 4,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gray200, width: 1.5),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(colors[0]), Color(colors[1])],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              displayChar,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: size + 6,
      height: size + 6,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.accentHighlight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(colors[0]), Color(colors[1])],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            displayChar,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 点阵底纹
class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter({required this.dotColor});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const step = 14.0;
    for (var x = 0.0; x < size.width; x += step) {
      for (var y = 0.0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x + 2, y + 2), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor;
  }
}
