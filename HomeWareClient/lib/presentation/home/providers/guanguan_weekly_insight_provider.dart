import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assistant/guanguan_weekly_insight_builder.dart';
import '../../../core/assistant/guanguan_weekly_insight_models.dart';
import '../../../core/events/item_event_bus.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/home_provider.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/services/guanguan_weekly_insight_prefs.dart';
import '../../../core/services/profile_health_history_service.dart';

/// 管管周报 Insight — 本周未收起且有内容时返回
final guanguanWeeklyInsightProvider =
    FutureProvider<GuanguanWeeklyInsight?>((ref) async {
  ref.watch(itemEventBusProvider);
  ref.watch(homeStatsProvider);
  final skin = ref.watch(spaceSkinProvider);

  if (await GuanguanWeeklyInsightPrefs.isDismissedThisWeek()) {
    return null;
  }

  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final records = await db.getRecentUsageRecords(limit: 800);
  final items = await db.getAllItems();
  final health = await ProfileHealthHistoryService.load();

  final insight = GuanguanWeeklyInsightBuilder.build(
    recentRecords: records,
    allItems: items,
    healthHistory: health,
    skin: skin,
  );

  if (!insight.hasContent) {
    debugPrint('[guanguanWeeklyInsightProvider] INFO: 本周无足够数据，隐藏周报');
    return null;
  }

  debugPrint(
    '[guanguanWeeklyInsightProvider] INFO: achievement=${insight.achievement} '
    'record=${insight.recordCount} consume=${insight.consumeCount}',
  );
  return insight;
});
