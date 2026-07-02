import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/home_provider.dart';

/// 单日健康分快照
class ProfileHealthSnapshot {
  const ProfileHealthSnapshot({
    required this.date,
    required this.score,
  });

  final DateTime date;
  final int score;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'score': score,
      };

  factory ProfileHealthSnapshot.fromJson(Map<String, dynamic> json) {
    return ProfileHealthSnapshot(
      date: DateTime.parse(json['date'] as String),
      score: json['score'] as int? ?? 0,
    );
  }
}

/// 健康分历史 — SharedPreferences 保留近 14 天
class ProfileHealthHistoryService {
  ProfileHealthHistoryService._();

  static const _storageKey = 'profile_health_history_v1';
  static const _maxDays = 14;

  /// 根据首页统计写入/更新今日快照
  static Future<void> recordFromStats(HomeStats stats) async {
    try {
      final score = _scoreFromStats(stats);

      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      final list = await _loadRaw(prefs);
      final filtered = list
          .where(
            (s) => !_isSameDay(s.date, todayDate),
          )
          .toList()
        ..add(ProfileHealthSnapshot(date: todayDate, score: score));

      filtered.sort((a, b) => a.date.compareTo(b.date));
      final trimmed = filtered.length > _maxDays
          ? filtered.sublist(filtered.length - _maxDays)
          : filtered;

      await prefs.setString(
        _storageKey,
        jsonEncode(trimmed.map((e) => e.toJson()).toList()),
      );
      debugPrint('[ProfileHealthHistory] INFO: 记录今日健康分 $score');
    } catch (e) {
      debugPrint('[ProfileHealthHistory] ERROR: 记录失败 $e');
    }
  }

  static Future<List<ProfileHealthSnapshot>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await _loadRaw(prefs);
    } catch (e) {
      debugPrint('[ProfileHealthHistory] ERROR: 读取失败 $e');
      return [];
    }
  }

  static Future<List<ProfileHealthSnapshot>> _loadRaw(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ProfileHealthSnapshot.fromJson)
        .toList();
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int _scoreFromStats(HomeStats stats) {
    final penalty = stats.expiredCount * 12 +
        stats.expiringCount * 6 +
        stats.lowStockCount * 4;
    return (100 - penalty).clamp(35, 100);
  }
}
