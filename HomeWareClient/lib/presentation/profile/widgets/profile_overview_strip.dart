import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';

/// 个人中心数据概览条 — 渐变顶条 + 紧迫脉冲点
class ProfileOverviewStrip extends StatelessWidget {
  const ProfileOverviewStrip({
    super.key,
    required this.tiles,
  });

  final List<ProfileOverviewTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _OverviewTile(data: tiles[i], index: i)),
        ],
      ],
    );
  }
}

/// 单个概览指标
class ProfileOverviewTile {
  const ProfileOverviewTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.onTap,
    this.urgent = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool urgent;
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({required this.data, required this.index});

  final ProfileOverviewTile data;
  final int index;

  @override
  Widget build(BuildContext context) {
    final utility = AppColors.isUtilityStyle;

    return Material(
      color: AppColors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: data.onTap == null
            ? null
            : () {
                debugPrint('[ProfileOverviewStrip] INFO: 点击 ${data.label}');
                data.onTap!();
              },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: data.urgent
                  ? data.accentColor.withValues(alpha: utility ? 0.35 : 0.45)
                  : AppColors.homeDivider,
              width: data.urgent ? 1.5 : 1,
            ),
            gradient: utility
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      data.accentColor.withValues(
                        alpha: data.urgent ? 0.1 : 0.06,
                      ),
                      AppColors.white,
                    ],
                  ),
            color: utility ? AppColors.white : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部色条 — 工具风仅 2px 实线
              Container(
                height: utility ? 2 : 3,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.md),
                  ),
                  color: utility
                      ? data.accentColor.withValues(alpha: 0.55)
                      : null,
                  gradient: utility
                      ? null
                      : LinearGradient(
                          colors: [
                            data.accentColor,
                            data.accentColor.withValues(alpha: 0.5),
                          ],
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) {
                            final (wellBg, wellFg) =
                                AppColors.iconWellFor(data.accentColor);
                            return Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: wellBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                data.icon,
                                size: 17,
                                color: wellFg,
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        if (data.urgent) const _PulseDot(),
                      ],
                    ),
                    SizedBox(height: index == 0 ? 12 : 10),
                    Text(
                      data.value,
                      style: TextStyle(
                        fontSize: index == 0 ? 22 : 20,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        color: data.urgent && !utility
                            ? data.accentColor
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 紧迫指标脉冲点
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8 + _controller.value * 4,
          height: 8 + _controller.value * 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.danger.withValues(
              alpha: 0.35 + _controller.value * 0.35,
            ),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
