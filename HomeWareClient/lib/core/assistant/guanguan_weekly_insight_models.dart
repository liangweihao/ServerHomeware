/// 管管 P2 — 周报 Insight 与成就
enum GuanguanAchievementKind {
  /// 健康分连续 7 天满分（无临期/过期/低库存）
  zeroWasteWeek,
}

/// 周报 Insight 数据
class GuanguanWeeklyInsight {
  const GuanguanWeeklyInsight({
    required this.weekLabel,
    required this.headline,
    required this.summaryLines,
    this.achievement,
    required this.recordCount,
    required this.consumeCount,
    required this.newItemCount,
    required this.greenStreakDays,
  });

  final String weekLabel;
  final String headline;
  final List<String> summaryLines;
  final GuanguanAchievementKind? achievement;
  final int recordCount;
  final int consumeCount;
  final int newItemCount;
  final int greenStreakDays;

  bool get hasContent =>
      recordCount > 0 ||
      consumeCount > 0 ||
      newItemCount > 0 ||
      achievement != null ||
      greenStreakDays >= 3;
}
