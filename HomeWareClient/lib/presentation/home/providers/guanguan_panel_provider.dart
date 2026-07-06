import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assistant/guanguan_panel_builder.dart';
import '../../../core/assistant/guanguan_panel_models.dart';
import '../../../core/events/item_event_bus.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/home_provider.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/services/guanguan_panel_prefs.dart';
import '../../../core/utils/item_list_reason_helper.dart';
import '../../profile/providers/family_contribution_provider.dart';

/// 管管今日面板数据
final guanguanPanelProvider = FutureProvider<GuanguanPanelData>((ref) async {
  ref.watch(itemEventBusProvider);
  ref.watch(homeStatsProvider);
  final skin = ref.watch(spaceSkinProvider);

  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final allItems = await db.getAllItems();
  final active = allItems.where((i) => i.status == 0).toList();
  final locations = await db.getAllLocations();
  final locationById = {for (final l in locations) l.id: l};

  final tasks = GuanguanPanelBuilder.buildTasks(active);

  final defaultSpace =
      locations.where((l) => l.name == skin.defaultSpaceName && l.level == 1).firstOrNull;
  final records = await db.getRecentUsageRecords(limit: 800);

  final proficiency = GuanguanPanelBuilder.buildSpaceProficiency(
    spaceName: skin.defaultSpaceName,
    spaceRootLocationId: defaultSpace?.id,
    allItems: allItems,
    recentRecords: records,
    locationById: locationById,
  );

  final members = await ref.watch(familyContributionLeaderboardProvider.future);
  final memberStats = members
      .map((m) => (name: m.name, record: m.recordCount, consume: m.consumeCount))
      .toList();
  final quip = GuanguanPanelBuilder.buildCollaborationQuip(
    members: memberStats,
    skin: skin,
  );

  final idle = GuanguanPanelBuilder.buildIdleInsight(
    activeItems: active,
    recentRecords: records,
  );

  final pendingCount =
      active.where((i) => computeItemListReason(i).isActionable).length;

  final data = GuanguanPanelData(
    tasks: tasks,
    proficiency: proficiency,
    collaborationQuip: quip,
    idleInsight: idle,
    allClear: pendingCount == 0,
  );

  debugPrint(
    '[guanguanPanelProvider] INFO: tasks=${tasks.length} '
    'lv=${proficiency.level} allClear=${data.allClear}',
  );
  return data;
});

/// 面板折叠态（本地持久化）
final guanguanPanelCollapsedProvider =
    StateNotifierProvider<GuanguanPanelCollapsedNotifier, bool>(
  (ref) => GuanguanPanelCollapsedNotifier(),
);

class GuanguanPanelCollapsedNotifier extends StateNotifier<bool> {
  GuanguanPanelCollapsedNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    state = await GuanguanPanelPrefs.isCollapsed();
  }

  Future<void> toggle() async {
    state = !state;
    await GuanguanPanelPrefs.setCollapsed(state);
  }
}
