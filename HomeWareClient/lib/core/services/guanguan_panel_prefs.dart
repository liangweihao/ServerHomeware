import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// 管管面板本地偏好 — 折叠态与每日结算
class GuanguanPanelPrefs {
  GuanguanPanelPrefs._();

  static const _collapsedKey = 'guanguan_panel_collapsed_v1';
  static const _settlementDateKey = 'guanguan_daily_settlement_date_v1';

  static Future<bool> isCollapsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_collapsedKey) ?? false;
  }

  static Future<void> setCollapsed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_collapsedKey, value);
    debugPrint('[GuanguanPanelPrefs] INFO: collapsed=$value');
  }

  /// 今日是否已展示「危机化解」结算
  static Future<bool> hasShownSettlementToday() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_settlementDateKey);
    if (saved == null) return false;
    return saved == _todayKey();
  }

  static Future<void> markSettlementShownToday() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settlementDateKey, _todayKey());
    debugPrint('[GuanguanPanelPrefs] INFO: 每日结算已展示');
  }

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }
}
