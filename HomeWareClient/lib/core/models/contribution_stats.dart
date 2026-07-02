/// 贡献度 API 字段解析 — 对齐服务端 added_items/used_count 与客户端 record_count/consume_count
class UserContributionStats {
  const UserContributionStats({
    required this.recordCount,
    required this.consumeCount,
    required this.contributionPercent,
    this.ranking,
    this.totalScore,
  });

  final int recordCount;
  final int consumeCount;
  final int contributionPercent;
  final int? ranking;
  final int? totalScore;

  /// 从 API data 解析，兼容新旧字段名
  factory UserContributionStats.fromApi(Map<String, dynamic>? data) {
    if (data == null) {
      return const UserContributionStats(
        recordCount: 0,
        consumeCount: 0,
        contributionPercent: 0,
      );
    }
    final record = _asInt(data['record_count'] ?? data['added_items']);
    final consume = _asInt(data['consume_count'] ?? data['used_count']);
    final contribution = _asInt(data['contribution']);
    return UserContributionStats(
      recordCount: record,
      consumeCount: consume,
      contributionPercent: contribution.clamp(0, 100),
      ranking: data['ranking'] != null ? _asInt(data['ranking']) : null,
      totalScore: data['total_score'] != null ? _asInt(data['total_score']) : null,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value') ?? 0;
  }
}

/// 家庭成员排行条目
class FamilyLeaderboardEntry {
  const FamilyLeaderboardEntry({
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

  factory FamilyLeaderboardEntry.fromApi(Map<String, dynamic> json) {
    return FamilyLeaderboardEntry(
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : '未署名',
      recordCount: UserContributionStats._asInt(
        json['record_count'] ?? json['added_items'],
      ),
      consumeCount: UserContributionStats._asInt(
        json['consume_count'] ?? json['used_count'],
      ),
      rank: json['rank'] != null ? UserContributionStats._asInt(json['rank']) : null,
      userId: json['user_id'] != null ? UserContributionStats._asInt(json['user_id']) : null,
    );
  }
}
