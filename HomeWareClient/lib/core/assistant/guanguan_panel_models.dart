/// 管管今日面板 — 数据模型（P1）
enum GuanguanTaskKind {
  expiry,
  lowStock,
  other,
}

/// 今日待办任务（最多展示 3 条）
class GuanguanTask {
  const GuanguanTask({
    required this.itemId,
    required this.itemName,
    required this.subtitle,
    required this.kind,
  });

  final int itemId;
  final String itemName;
  final String subtitle;
  final GuanguanTaskKind kind;
}

/// 空间熟练度（默认厨房）
class SpaceProficiency {
  const SpaceProficiency({
    required this.spaceName,
    required this.level,
    required this.recentActions,
  });

  final String spaceName;
  final int level;

  /// 近 7 日录入 + 消耗次数
  final int recentActions;
}

/// 管管面板聚合数据
class GuanguanPanelData {
  const GuanguanPanelData({
    required this.tasks,
    required this.proficiency,
    this.collaborationQuip,
    this.idleInsight,
    required this.allClear,
  });

  final List<GuanguanTask> tasks;
  final SpaceProficiency proficiency;
  final String? collaborationQuip;

  /// 隐藏洞察：长期未动用的物品，携带 itemId 用于点击跳转
  final ({String text, int itemId})? idleInsight;

  /// 无待处理提醒
  final bool allClear;

  static const empty = GuanguanPanelData(
    tasks: [],
    proficiency: SpaceProficiency(
      spaceName: '厨房',
      level: 1,
      recentActions: 0,
    ),
    allClear: true,
  );
}
