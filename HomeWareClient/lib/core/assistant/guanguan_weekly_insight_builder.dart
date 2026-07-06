import '../config/space_skin_config.dart';
import '../../data/database/app_database.dart';
import '../services/profile_health_history_service.dart';
import 'guanguan_weekly_insight_models.dart';

/// 管管周报 Insight 构建 — 纯函数，便于单测
abstract final class GuanguanWeeklyInsightBuilder {
  static const greenScoreThreshold = 100;
  static const zeroWasteStreakDays = 7;

  /// 近 7 日滚动窗口统计 + 健康分连续绿判定
  static GuanguanWeeklyInsight build({
    required List<UsageRecord> recentRecords,
    required List<Item> allItems,
    required List<ProfileHealthSnapshot> healthHistory,
    SpaceSkinConfig skin = SpaceSkinConfig.home,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final weekStart = clock.subtract(const Duration(days: 7));
    final today = DateTime(clock.year, clock.month, clock.day);

    var recordCount = 0;
    var consumeCount = 0;
    for (final r in recentRecords) {
      if (r.createdAt.isBefore(weekStart)) continue;
      if (r.type == 0) {
        recordCount++;
      } else if (r.type == 1) {
        consumeCount++;
      }
    }

    var newItemCount = 0;
    for (final item in allItems) {
      if (item.status != 0) continue;
      if (!item.createdAt.isBefore(weekStart)) {
        newItemCount++;
      }
    }

    final greenStreak = _consecutiveGreenDays(healthHistory, today: today);
    GuanguanAchievementKind? achievement;
    if (greenStreak >= zeroWasteStreakDays) {
      achievement = GuanguanAchievementKind.zeroWasteWeek;
    }

    final weekLabel = skin.weeklyInsightLabel(clock);
    final headline = skin.weeklyInsightHeadline(
      achievement: achievement,
      recordCount: recordCount,
      consumeCount: consumeCount,
    );
    final summaryLines = skin.weeklyInsightSummaryLines(
      recordCount: recordCount,
      consumeCount: consumeCount,
      newItemCount: newItemCount,
      greenStreakDays: greenStreak,
    );

    return GuanguanWeeklyInsight(
      weekLabel: weekLabel,
      headline: headline,
      summaryLines: summaryLines,
      achievement: achievement,
      recordCount: recordCount,
      consumeCount: consumeCount,
      newItemCount: newItemCount,
      greenStreakDays: greenStreak,
    );
  }

  /// 从今天往回数连续「满分绿」天数（缺日则断档）
  static int _consecutiveGreenDays(
    List<ProfileHealthSnapshot> snapshots, {
    required DateTime today,
  }) {
    final scoreByDay = {
      for (final s in snapshots) _dayKey(s.date): s.score,
    };

    var streak = 0;
    for (var i = 0; i < 14; i++) {
      final day = today.subtract(Duration(days: i));
      final score = scoreByDay[_dayKey(day)];
      if (score == null || score < greenScoreThreshold) break;
      streak++;
    }
    return streak;
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
