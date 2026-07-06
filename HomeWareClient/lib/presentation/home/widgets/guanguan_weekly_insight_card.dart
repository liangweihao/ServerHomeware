import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/space_skin_config.dart';
import '../../../core/assistant/guanguan_weekly_insight_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/assistant_mascot.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/services/guanguan_weekly_insight_prefs.dart';
import '../providers/guanguan_weekly_insight_provider.dart';
import 'guanguan_backpack_reveal.dart';

/// 管管 P2 — 周报「单元剧复盘」Insight 卡
class GuanguanWeeklyInsightCard extends ConsumerWidget {
  const GuanguanWeeklyInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightAsync = ref.watch(guanguanWeeklyInsightProvider);

    return insightAsync.when(
      data: (insight) {
        if (insight == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _WeeklyInsightBody(
            insight: insight,
            onDismiss: () async {
              await GuanguanWeeklyInsightPrefs.dismissThisWeek();
              ref.invalidate(guanguanWeeklyInsightProvider);
              debugPrint('[GuanguanWeeklyInsightCard] INFO: 用户收起本周周报');
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) {
        debugPrint('[GuanguanWeeklyInsightCard] ERROR: $e');
        return const SizedBox.shrink();
      },
    );
  }
}

class _WeeklyInsightBody extends StatelessWidget {
  const _WeeklyInsightBody({
    required this.insight,
    required this.onDismiss,
  });

  final GuanguanWeeklyInsight insight;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final hasAchievement = insight.achievement != null;

    return Material(
      color: AppColors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GuanguanBackpackReveal(
                  size: 44,
                  highlight: hasAchievement,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.weekLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        insight.headline,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close, size: 18, color: AppColors.textHint),
                  onPressed: onDismiss,
                  tooltip: '本周不再显示',
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...insight.summaryLines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.accentTeal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        line,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (hasAchievement) ...[
              const SizedBox(height: 10),
              _AchievementBadge(kind: insight.achievement!),
            ],
            const SizedBox(height: 6),
            Text(
              '${AssistantMascot.name}说：像单元剧大结局，下周继续烟火日常～',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends ConsumerWidget {
  const _AchievementBadge({required this.kind});

  final GuanguanAchievementKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(spaceSkinProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.successLight,
            AppColors.success.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, color: AppColors.success, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skin.achievementTitle(kind),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  skin.achievementSubtitle(kind),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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
