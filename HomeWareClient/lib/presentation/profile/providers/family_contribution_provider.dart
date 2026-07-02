import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/item_event_bus.dart';
import '../../../core/models/contribution_stats.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/contribution_service.dart';
import '../../../core/services/usage_record_sync_service.dart';
import '../../../data/database/app_database.dart';

/// 家庭成员贡献统计（本月）
class FamilyMemberContribution {
  const FamilyMemberContribution({
    required this.name,
    required this.recordCount,
    required this.consumeCount,
    this.rank,
    this.userId,
  });

  final String name;
  final int recordCount;
  final int consumeCount;
  final int? rank;
  final int? userId;

  int get totalActions => recordCount + consumeCount;

  factory FamilyMemberContribution.fromEntry(FamilyLeaderboardEntry e) {
    return FamilyMemberContribution(
      name: e.name,
      recordCount: e.recordCount,
      consumeCount: e.consumeCount,
      rank: e.rank,
      userId: e.userId,
    );
  }
}

/// 家庭动态条目（含物品名，可跳转详情）
class FamilyActivityEntry {
  const FamilyActivityEntry({
    required this.record,
    required this.itemName,
  });

  final UsageRecord record;
  final String itemName;
}

List<FamilyMemberContribution> _buildLocalLeaderboard(List<UsageRecord> monthRecords) {
  final map = <String, FamilyMemberContribution>{};

  void bump(String name, {bool isRecord = false, bool isConsume = false}) {
    final key = name.isEmpty ? '未署名' : name;
    final prev = map[key];
    map[key] = FamilyMemberContribution(
      name: key,
      recordCount: (prev?.recordCount ?? 0) + (isRecord ? 1 : 0),
      consumeCount: (prev?.consumeCount ?? 0) + (isConsume ? 1 : 0),
      rank: prev?.rank,
      userId: prev?.userId,
    );
  }

  for (final r in monthRecords) {
    final operator = r.operatorName?.trim() ?? '未署名';
    switch (r.type) {
      case 0:
        bump(operator, isRecord: true);
      case 1:
        bump(operator, isConsume: true);
      default:
        break;
    }
  }

  final list = map.values.toList()
    ..sort((a, b) => b.totalActions.compareTo(a.totalActions));
  return list;
}

/// 合并本地与服务端排行 — 按姓名取较大值，避免重复统计丢失
List<FamilyMemberContribution> _mergeLeaderboards(
  List<FamilyMemberContribution> local,
  List<FamilyMemberContribution> server,
) {
  final merged = <String, FamilyMemberContribution>{};

  for (final m in [...local, ...server]) {
    final prev = merged[m.name];
    if (prev == null) {
      merged[m.name] = m;
    } else {
      merged[m.name] = FamilyMemberContribution(
        name: m.name,
        recordCount: prev.recordCount > m.recordCount ? prev.recordCount : m.recordCount,
        consumeCount: prev.consumeCount > m.consumeCount ? prev.consumeCount : m.consumeCount,
        rank: m.rank ?? prev.rank,
        userId: m.userId ?? prev.userId,
      );
    }
  }

  final list = merged.values.toList()
    ..sort((a, b) => b.totalActions.compareTo(a.totalActions));
  return list;
}

/// 家庭贡献排行 — 本地 usage_records + 服务端 API 合并
final familyContributionLeaderboardProvider =
    FutureProvider<List<FamilyMemberContribution>>((ref) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  // 双向同步 usage_records，保证家庭排行跨设备一致
  try {
    await UsageRecordSyncService(db).syncBidirectional();
  } catch (e) {
    debugPrint('[FamilyContribution] WARN: usage 同步失败 $e');
  }

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final records = await db.getRecentUsageRecords(limit: 500);
  final monthRecords =
      records.where((r) => !r.createdAt.isBefore(monthStart)).toList();
  final local = _buildLocalLeaderboard(monthRecords);

  try {
    final response = await ContributionService().getFamilyLeaderboard();
    if (response.code == 200 && response.data != null) {
      final members = response.data!['members'];
      if (members is List && members.isNotEmpty) {
        final server = members
            .whereType<Map<String, dynamic>>()
            .map(FamilyLeaderboardEntry.fromApi)
            .map(FamilyMemberContribution.fromEntry)
            .toList();
        final merged = _mergeLeaderboards(local, server);
        debugPrint('[FamilyContribution] INFO: 合并排行 ${merged.length} 人');
        return merged;
      }
    }
  } catch (e) {
    debugPrint('[FamilyContribution] WARN: 服务端排行失败，使用本地 $e');
  }

  debugPrint('[FamilyContribution] INFO: 本地排行 ${local.length} 人');
  return local;
});

/// 最近家庭动态（含物品名）
final familyRecentActivityProvider =
    FutureProvider<List<FamilyActivityEntry>>((ref) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  try {
    await UsageRecordSyncService(db).syncBidirectional();
  } catch (e) {
    debugPrint('[FamilyContribution] WARN: 动态同步失败 $e');
  }
  final records = await db.getRecentUsageRecords(limit: 12);
  final items = await db.getAllItems();
  final nameById = {for (final i in items) i.id: i.name};

  return records
      .map(
        (r) => FamilyActivityEntry(
          record: r,
          itemName: nameById[r.itemId] ?? '物品 #${r.itemId}',
        ),
      )
      .toList();
});

/// 指定成员最近动态 — 按操作人姓名筛选
final memberActivityByNameProvider = FutureProvider.family<
    List<FamilyActivityEntry>,
    String>((ref, operatorName) async {
  final all = await ref.watch(familyRecentActivityProvider.future);
  return all
      .where(
        (e) => (e.record.operatorName?.trim().isNotEmpty == true
                ? e.record.operatorName!.trim()
                : '未署名') ==
            operatorName,
      )
      .take(10)
      .toList();
});

/// 成员按分类的操作统计（本月）
class MemberCategoryStat {
  const MemberCategoryStat({
    required this.categoryName,
    required this.recordCount,
    required this.consumeCount,
  });

  final String categoryName;
  final int recordCount;
  final int consumeCount;

  int get total => recordCount + consumeCount;
}

String _normalizeOperatorName(String? name) {
  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) return '未署名';
  return trimmed;
}

/// 成员本月各分类录入/消耗分布
final memberCategoryStatsProvider = FutureProvider.family<
    List<MemberCategoryStat>,
    String>((ref, operatorName) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final records = await db.getRecentUsageRecords(limit: 500);
  final monthRecords = records
      .where((r) => !r.createdAt.isBefore(monthStart))
      .where((r) => _normalizeOperatorName(r.operatorName) == operatorName);

  if (monthRecords.isEmpty) {
    debugPrint('[MemberCategoryStats] INFO: $operatorName 无本月记录');
    return [];
  }

  final items = await db.getAllItems();
  final itemById = {for (final i in items) i.id: i};
  final categoryNameCache = <int, String>{};

  Future<String> categoryNameFor(int categoryId) async {
    if (categoryNameCache.containsKey(categoryId)) {
      return categoryNameCache[categoryId]!;
    }
    final cat = await db.getCategoryById(categoryId);
    final name = cat?.name ?? '未分类';
    categoryNameCache[categoryId] = name;
    return name;
  }

  final map = <String, ({int record, int consume})>{};

  for (final r in monthRecords) {
    final item = itemById[r.itemId];
    final catName = item != null
        ? await categoryNameFor(item.categoryId)
        : '未分类';
    final prev = map[catName] ?? (record: 0, consume: 0);
    map[catName] = (
      record: prev.record + (r.type == 0 ? 1 : 0),
      consume: prev.consume + (r.type == 1 ? 1 : 0),
    );
  }

  final list = map.entries
      .map(
        (e) => MemberCategoryStat(
          categoryName: e.key,
          recordCount: e.value.record,
          consumeCount: e.value.consume,
        ),
      )
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));

  debugPrint('[MemberCategoryStats] INFO: $operatorName 共 ${list.length} 个分类');
  return list.take(8).toList();
});

/// 成员操作类型统计（本月）
class MemberOperationTypeStat {
  const MemberOperationTypeStat({
    required this.type,
    required this.label,
    required this.count,
  });

  final int type;
  final String label;
  final int count;
}

/// 成员本月各操作类型分布 — 供饼图展示
final memberOperationTypeStatsProvider = FutureProvider.family<
    List<MemberOperationTypeStat>,
    String>((ref, operatorName) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final records = await db.getRecentUsageRecords(limit: 500);
  final monthRecords = records
      .where((r) => !r.createdAt.isBefore(monthStart))
      .where((r) => _normalizeOperatorName(r.operatorName) == operatorName);

  if (monthRecords.isEmpty) {
    debugPrint('[MemberOperationTypeStats] INFO: $operatorName 无本月记录');
    return [];
  }

  final counts = <int, int>{};
  for (final r in monthRecords) {
    counts[r.type] = (counts[r.type] ?? 0) + 1;
  }

  String labelFor(int type) => switch (type) {
        0 => '入库',
        1 => '消耗',
        2 => '丢弃',
        3 => '移动',
        4 => '调整',
        _ => '其他',
      };

  final list = counts.entries
      .map(
        (e) => MemberOperationTypeStat(
          type: e.key,
          label: labelFor(e.key),
          count: e.value,
        ),
      )
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  debugPrint(
    '[MemberOperationTypeStats] INFO: $operatorName 共 ${list.length} 种操作类型',
  );
  return list;
});
