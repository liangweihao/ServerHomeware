import 'dart:math' as math;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/icons/candy_icon.dart';
import '../../../core/icons/candy_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import 'profile_inventory_health.dart';

/// 库存健康度圆环 — 渐变弧 + 分数过渡动画
class ProfileHealthRing extends StatefulWidget {
  const ProfileHealthRing({
    super.key,
    required this.health,
    this.size = 72,
    this.onTap,
  });

  final ProfileInventoryHealth health;
  final double size;
  final VoidCallback? onTap;

  @override
  State<ProfileHealthRing> createState() => _ProfileHealthRingState();
}

class _ProfileHealthRingState extends State<ProfileHealthRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnim;
  late Animation<int> _scoreAnim;
  double _displayProgress = 0;
  int _displayScore = 0;

  @override
  void initState() {
    super.initState();
    _displayProgress =
        widget.health.score <= 0 ? 0 : widget.health.score / 100;
    _displayScore = widget.health.score;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _setupAnimations(_displayProgress, _displayScore);
    _controller.value = 1;
  }

  void _setupAnimations(double targetProgress, int targetScore) {
    _progressAnim = Tween<double>(
      begin: _displayProgress,
      end: targetProgress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scoreAnim = IntTween(begin: _displayScore, end: targetScore).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(ProfileHealthRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.health.score != widget.health.score) {
      _displayProgress = _progressAnim.value;
      _displayScore = _scoreAnim.value;
      final target =
          widget.health.score <= 0 ? 0.0 : widget.health.score / 100;
      _setupAnimations(target, widget.health.score);
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final health = widget.health;
    final size = widget.size;

    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : () {
              debugPrint('[ProfileHealthRing] INFO: 点击健康度');
              widget.onTap!();
            },
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _progressAnim.value;
            final score = _scoreAnim.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _RingPainter(
                    progress: progress,
                    trackColor: AppColors.gray200,
                    gradientColors: [
                      health.color,
                      health.color.withValues(alpha: 0.55),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: size * 0.26,
                        fontWeight: FontWeight.w800,
                        color: health.color,
                        height: 1,
                      ),
                      child: Text(score <= 0 ? '—' : '$score'),
                    ),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: size * 0.13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      child: Text(health.label),
                    ),
                  ],
                ),
                if (health.hasIssues)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.danger.withValues(alpha: 0.45),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 健康度横幅 — 圆环 + 提示文案横条
class ProfileHealthBanner extends StatelessWidget {
  const ProfileHealthBanner({
    super.key,
    required this.health,
    this.onTap,
  });

  final ProfileInventoryHealth health;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Material(
        color: AppColors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.homeDivider),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  health.color.withValues(alpha: 0.08),
                  AppColors.white,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  ProfileHealthRing(health: health, size: 56, onTap: onTap),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '家庭库存健康度',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 400),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          child: Text(health.hint),
                        ),
                      ],
                    ),
                  ),
                  const CandyIcon(CandyIcons.chevronRight, color: AppColors.textHint, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.gradientColors,
  });

  final double progress;
  final Color trackColor;
  final List<Color> gradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    const stroke = 6.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweep = 2 * math.pi * progress;
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        colors: gradientColors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor;
  }
}
