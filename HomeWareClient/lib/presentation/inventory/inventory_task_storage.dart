import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 盘点修正明细
class InventoryAdjustmentDetail {
  const InventoryAdjustmentDetail({
    required this.itemName,
    required this.oldQty,
    required this.newQty,
    required this.unit,
  });

  final String itemName;
  final double oldQty;
  final double newQty;
  final String unit;

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'oldQty': oldQty,
        'newQty': newQty,
        'unit': unit,
      };

  factory InventoryAdjustmentDetail.fromJson(Map<String, dynamic> json) {
    return InventoryAdjustmentDetail(
      itemName: json['itemName']?.toString() ?? '',
      oldQty: (json['oldQty'] as num?)?.toDouble() ?? 0,
      newQty: (json['newQty'] as num?)?.toDouble() ?? 0,
      unit: json['unit']?.toString() ?? '',
    );
  }
}

/// 盘点历史记录（本地）
class InventoryHistoryEntry {
  const InventoryHistoryEntry({
    required this.completedAt,
    required this.locationName,
    required this.totalCount,
    required this.confirmedCount,
    required this.adjustedCount,
    required this.skippedCount,
    this.expiredAlertCount = 0,
    this.expiringAlertCount = 0,
    this.adjustments = const [],
  });

  final DateTime completedAt;
  final String locationName;
  final int totalCount;
  final int confirmedCount;
  final int adjustedCount;
  final int skippedCount;
  /// 盘点时发现已过期物品数
  final int expiredAlertCount;
  /// 盘点时发现 7 日内临期物品数
  final int expiringAlertCount;
  final List<InventoryAdjustmentDetail> adjustments;

  Map<String, dynamic> toJson() => {
        'completedAt': completedAt.toIso8601String(),
        'locationName': locationName,
        'totalCount': totalCount,
        'confirmedCount': confirmedCount,
        'adjustedCount': adjustedCount,
        'skippedCount': skippedCount,
        'expiredAlertCount': expiredAlertCount,
        'expiringAlertCount': expiringAlertCount,
        'adjustments': adjustments.map((e) => e.toJson()).toList(),
      };

  factory InventoryHistoryEntry.fromJson(Map<String, dynamic> json) {
    final rawAdj = json['adjustments'];
    final adjustments = rawAdj is List
        ? rawAdj
            .whereType<Map<String, dynamic>>()
            .map(InventoryAdjustmentDetail.fromJson)
            .toList()
        : <InventoryAdjustmentDetail>[];

    return InventoryHistoryEntry(
      completedAt: DateTime.parse(json['completedAt'] as String),
      locationName: json['locationName']?.toString() ?? '',
      totalCount: json['totalCount'] as int? ?? 0,
      confirmedCount: json['confirmedCount'] as int? ?? 0,
      adjustedCount: json['adjustedCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
      expiredAlertCount: json['expiredAlertCount'] as int? ?? 0,
      expiringAlertCount: json['expiringAlertCount'] as int? ?? 0,
      adjustments: adjustments,
    );
  }
}

/// 盘点历史持久化
class InventoryTaskStorage {
  InventoryTaskStorage._();

  static const _key = 'inventory_history_v1';
  static const _maxEntries = 20;

  static Future<void> append(InventoryHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    list.insert(0, entry);
    if (list.length > _maxEntries) {
      list.removeRange(_maxEntries, list.length);
    }
    final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, encoded);
    debugPrint('[InventoryTaskStorage] INFO: 已保存盘点记录 ${entry.locationName}');
  }

  static Future<List<InventoryHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) {
          try {
            return InventoryHistoryEntry.fromJson(
              jsonDecode(s) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<InventoryHistoryEntry>()
        .toList();
  }
}
