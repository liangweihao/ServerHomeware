import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// 管管周报 Insight — 本周是否已收起
class GuanguanWeeklyInsightPrefs {
  GuanguanWeeklyInsightPrefs._();

  static const _dismissWeekKey = 'guanguan_weekly_insight_dismiss_v1';

  /// 当前自然周 key（以周一为起点）
  static String currentWeekKey([DateTime? now]) {
    final clock = now ?? DateTime.now();
    final monday = clock.subtract(Duration(days: clock.weekday - 1));
    return '${monday.year}-${monday.month}-${monday.day}';
  }

  static Future<bool> isDismissedThisWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_dismissWeekKey);
    final dismissed = saved == currentWeekKey();
    debugPrint('[GuanguanWeeklyInsightPrefs] INFO: dismissed=$dismissed');
    return dismissed;
  }

  static Future<void> dismissThisWeek() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissWeekKey, currentWeekKey());
    debugPrint('[GuanguanWeeklyInsightPrefs] INFO: 本周周报已收起');
  }
}
