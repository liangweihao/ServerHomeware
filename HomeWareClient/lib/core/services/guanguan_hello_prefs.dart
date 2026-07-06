import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// 管管 hello 动效偏好 — 每日首次进入问管管播放一次
class GuanguanHelloPrefs {
  GuanguanHelloPrefs._();

  static const _helloDateKey = 'guanguan_hello_shown_date_v1';

  /// 今日是否尚未播放 hello（应播放）
  static Future<bool> shouldPlayHelloToday() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_helloDateKey);
    final shouldPlay = saved != _todayKey();
    debugPrint('[GuanguanHelloPrefs] INFO: shouldPlayHelloToday=$shouldPlay');
    return shouldPlay;
  }

  /// 标记今日已播放 hello
  static Future<void> markHelloShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_helloDateKey, _todayKey());
    debugPrint('[GuanguanHelloPrefs] INFO: 今日 hello 已标记');
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
