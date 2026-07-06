import '../config/space_skin_config.dart';
import '../../data/database/app_database.dart';
import '../utils/item_list_reason_helper.dart';
import 'guanguan_panel_models.dart';

/// 管管面板数据构建 — 纯函数，便于单测
abstract final class GuanguanPanelBuilder {
  static const maxTasks = 3;
  static const proficiencyActionsPerLevel = 5;

  /// 从待处理物品生成今日任务（按紧急度 Top3）
  static List<GuanguanTask> buildTasks(List<Item> activeItems) {
    final pending =
        activeItems.where((i) => computeItemListReason(i).isActionable).toList();
    sortItemsByUrgency(pending);

    return pending.take(maxTasks).map((item) {
      final reason = computeItemListReason(item);
      final kind = reason.label.contains('库存')
          ? GuanguanTaskKind.lowStock
          : (reason.urgency >= 75
              ? GuanguanTaskKind.expiry
              : GuanguanTaskKind.other);
      return GuanguanTask(
        itemId: item.id,
        itemName: item.name,
        subtitle: reason.label,
        kind: kind,
      );
    }).toList();
  }

  /// 近 7 日空间内录入 + 消耗 → 熟练度等级
  static SpaceProficiency buildSpaceProficiency({
    required String spaceName,
    required int? spaceRootLocationId,
    required List<Item> allItems,
    required List<UsageRecord> recentRecords,
    required Map<int, Location> locationById,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final weekStart = clock.subtract(const Duration(days: 7));
    final itemIdsInSpace = <int>{};

    if (spaceRootLocationId != null) {
      for (final item in allItems) {
        if (item.status != 0 || item.locationId == null) continue;
        if (_isInSpaceTree(item.locationId!, spaceRootLocationId, locationById)) {
          itemIdsInSpace.add(item.id);
        }
      }
    }

    var actions = 0;
    for (final r in recentRecords) {
      if (r.createdAt.isBefore(weekStart)) continue;
      if (r.type != 0 && r.type != 1) continue;
      if (spaceRootLocationId != null && !itemIdsInSpace.contains(r.itemId)) {
        continue;
      }
      actions++;
    }

    final level = (actions ~/ proficiencyActionsPerLevel) + 1;
    return SpaceProficiency(
      spaceName: spaceName,
      level: level.clamp(1, 99),
      recentActions: actions,
    );
  }

  /// 成员协作态一句话
  static String? buildCollaborationQuip({
    required List<({String name, int record, int consume})> members,
    SpaceSkinConfig skin = SpaceSkinConfig.home,
  }) {
    if (members.isEmpty) return null;

    if (members.length == 1) {
      final m = members.first;
      if (m.record + m.consume >= 3) {
        return '最近主要是 ${m.name} 在维护库存，辛苦了';
      }
      return null;
    }

    final byRecord = [...members]..sort((a, b) => b.record.compareTo(a.record));
    final byConsume = [...members]..sort((a, b) => b.consume.compareTo(a.consume));
    final topRecord = byRecord.first;
    final topConsume = byConsume.first;

    return skin.collaborationQuip(
      recordLeader: topRecord.name,
      consumeLeader: topConsume.name,
      recordLeaderTotal: topRecord.total,
      multipleMembers: true,
    ) ??
        (topRecord.total >= 2
            ? '最近 ${topRecord.name} 最活跃，${skin.orgMemberQuipSuffix}'
            : null);
  }

  /// 30 天无消耗/入库的物品 → 隐藏洞察
  static String? buildIdleInsight({
    required List<Item> activeItems,
    required List<UsageRecord> recentRecords,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final threshold = clock.subtract(const Duration(days: 30));

    final lastTouchByItem = <int, DateTime>{};
    for (final r in recentRecords) {
      if (r.type != 0 && r.type != 1) continue;
      final prev = lastTouchByItem[r.itemId];
      if (prev == null || r.createdAt.isAfter(prev)) {
        lastTouchByItem[r.itemId] = r.createdAt;
      }
    }

    for (final item in activeItems) {
      if (item.status != 0) continue;
      final last = lastTouchByItem[item.id] ?? item.createdAt;
      if (last.isBefore(threshold)) {
        return '「${item.name}」30 天没动过了，还在吗？';
      }
    }
    return null;
  }

  static bool _isInSpaceTree(
    int itemLocationId,
    int spaceRootId,
    Map<int, Location> locationById,
  ) {
    var current = locationById[itemLocationId];
    while (current != null) {
      if (current.id == spaceRootId) return true;
      if (current.parentId == null) break;
      current = locationById[current.parentId];
    }
    return false;
  }
}

extension on ({String name, int record, int consume}) {
  int get total => record + consume;
}
