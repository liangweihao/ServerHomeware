import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assistant/daily_crisis_helper.dart';
import '../../../core/config/space_skin_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/models/alert_tab.dart';
import '../../../core/providers/home_provider.dart';
import '../../../core/providers/space_skin_provider.dart';

/// 每日一危机 Banner — 单主危机 + 次要统计，管管烟火语气
class TodaySummaryBanner extends ConsumerStatefulWidget {
  const TodaySummaryBanner({
    super.key,
    required this.stats,
    required this.onOpenAlerts,
  });

  final HomeStats stats;
  final VoidCallback onOpenAlerts;

  @override
  ConsumerState<TodaySummaryBanner> createState() => _TodaySummaryBannerState();
}

class _TodaySummaryBannerState extends ConsumerState<TodaySummaryBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartPulse());
  }

  void _maybeStartPulse() {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _detailLine(SpaceSkinConfig skin) {
    return skin.bannerDetailLine(
      expiredCount: widget.stats.expiredCount,
      expiringCount: widget.stats.expiringCount,
      lowStockCount: widget.stats.lowStockCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    final crisis = resolveDailyCrisis(
      widget.stats,
      spaceType: skin.spaceType,
    );
    if (crisis == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Material(
        color: AppColors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: () {
            debugPrint('[TodaySummary] INFO: 跳转提醒中心-主危机 ${crisis.kind}');
            widget.onOpenAlerts();
          },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ScaleTransition(
                      scale: _pulse,
                      child: Icon(
                        Icons.local_fire_department_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        crisis.headlineFor(skin),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.textHint),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  crisis.sublineFor(skin),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _detailLine(skin),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _QuickChip(
                      label: skin.crisisPrimaryChipLabel(crisis.kind),
                      highlighted: true,
                      onTap: () {
                        debugPrint('[TodaySummary] INFO: 跳转主危机 Tab');
                        context.push('/alerts?tab=${crisis.alertTab.name}');
                      },
                    ),
                    if (widget.stats.expiredCount > 0 &&
                        crisis.kind != DailyCrisisKind.expired)
                      _QuickChip(
                        label: '已过期',
                        onTap: () => context.push('/alerts?tab=${AlertTab.expiry.name}'),
                      ),
                    if (widget.stats.expiringCount > 0 &&
                        crisis.kind != DailyCrisisKind.expiring)
                      _QuickChip(
                        label: '临期',
                        onTap: () => context.push('/alerts?tab=${AlertTab.expiry.name}'),
                      ),
                    if (widget.stats.lowStockCount > 0 &&
                        crisis.kind != DailyCrisisKind.lowStock)
                      _QuickChip(
                        label: skin.lowStockChipLabel,
                        onTap: () => context.push('/alerts?tab=${AlertTab.stock.name}'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor:
          highlighted ? AppColors.primary : AppColors.primaryLighter,
      labelStyle: TextStyle(
        fontSize: 12,
        color: highlighted ? AppColors.white : AppColors.textPrimary,
        fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: highlighted
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.35),
      ),
      onPressed: onTap,
    );
  }
}
