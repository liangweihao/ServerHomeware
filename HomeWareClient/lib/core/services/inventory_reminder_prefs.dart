import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// 盘点提醒偏好 — 本地开关与提醒日（每月第几天）
class InventoryReminderPrefs {
  InventoryReminderPrefs._();

  static const _enabledKey = 'inventory_reminder_enabled_v1';
  static const _dayKey = 'inventory_reminder_day_v1';

  /// 默认每月 1 日提醒
  static const defaultDayOfMonth = 1;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    debugPrint('[InventoryReminderPrefs] INFO: enabled=$value');
  }

  static Future<int> dayOfMonth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dayKey) ?? defaultDayOfMonth;
  }

  static Future<void> setDayOfMonth(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dayKey, day.clamp(1, 28));
  }
}
