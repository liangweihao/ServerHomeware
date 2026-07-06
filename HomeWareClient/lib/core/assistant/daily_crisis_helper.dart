import '../config/space_skin_config.dart';
import '../models/alert_tab.dart';
import '../models/space_type.dart';
import '../providers/home_provider.dart';
import 'guanguan_copy.dart';

export 'guanguan_copy.dart' show DailyCrisisKind;

/// 每日一危机 — 从首页统计中解析「今天先处理哪一件」
class DailyCrisis {
  const DailyCrisis({
    required this.kind,
    required this.itemName,
    required this.totalIssues,
  });

  final DailyCrisisKind kind;
  final String itemName;

  /// 全部待处理件数（含主危机）
  final int totalIssues;

  /// 除主危机外的其余件数
  int get otherIssuesCount => (totalIssues - 1).clamp(0, totalIssues);

  String headlineFor(SpaceSkinConfig skin) => skin.dailyCrisisHeadline(
        itemName: itemName,
        kind: kind,
      );

  String sublineFor(SpaceSkinConfig skin) => skin.dailyCrisisSubline(
        otherCount: otherIssuesCount,
      );

  /// 家庭默认 headline（兼容旧引用）
  String get headline => headlineFor(SpaceSkinConfig.home);

  /// 家庭默认 subline（兼容旧引用）
  String get subline => sublineFor(SpaceSkinConfig.home);

  /// 主危机对应提醒中心 Tab
  AlertTab get alertTab => switch (kind) {
        DailyCrisisKind.expired || DailyCrisisKind.expiring => AlertTab.expiry,
        DailyCrisisKind.lowStock => AlertTab.stock,
      };
}

/// 危机选取策略 — home 过期优先，shop 断货/低库存优先
enum SpaceCrisisPriority {
  /// 已过期 > 临期 > 低库存（家庭默认）
  home,
  /// 低库存 > 临期 > 已过期（店铺默认）
  shop,
}

/// 由 [SpaceType] 映射危机优先级
SpaceCrisisPriority crisisPriorityFor(SpaceType type) =>
    type == SpaceType.shop ? SpaceCrisisPriority.shop : SpaceCrisisPriority.home;

/// 纯函数：按空间策略选取主危机
DailyCrisis? resolveDailyCrisis(
  HomeStats stats, {
  SpaceType spaceType = SpaceType.home,
}) {
  return resolveDailyCrisisWithPriority(
    stats,
    priority: crisisPriorityFor(spaceType),
  );
}

/// 显式指定优先级（便于单测）
DailyCrisis? resolveDailyCrisisWithPriority(
  HomeStats stats, {
  SpaceCrisisPriority priority = SpaceCrisisPriority.home,
}) {
  final total = stats.expiredCount + stats.expiringCount + stats.lowStockCount;
  if (total <= 0) return null;

  final order = switch (priority) {
    SpaceCrisisPriority.home => [
      _CrisisPick(DailyCrisisKind.expired, stats.expiredCount, stats.latestExpiredItem),
      _CrisisPick(DailyCrisisKind.expiring, stats.expiringCount, stats.latestExpiringItem),
      _CrisisPick(DailyCrisisKind.lowStock, stats.lowStockCount, stats.latestLowStockItem),
    ],
    SpaceCrisisPriority.shop => [
      _CrisisPick(DailyCrisisKind.lowStock, stats.lowStockCount, stats.latestLowStockItem),
      _CrisisPick(DailyCrisisKind.expiring, stats.expiringCount, stats.latestExpiringItem),
      _CrisisPick(DailyCrisisKind.expired, stats.expiredCount, stats.latestExpiredItem),
    ],
  };

  for (final pick in order) {
    if (pick.count > 0 && pick.itemName != null) {
      return DailyCrisis(
        kind: pick.kind,
        itemName: pick.itemName!,
        totalIssues: total,
      );
    }
  }

  return null;
}

class _CrisisPick {
  const _CrisisPick(this.kind, this.count, this.itemName);
  final DailyCrisisKind kind;
  final int count;
  final String? itemName;
}
