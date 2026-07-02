import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'profile_health_history_service.dart';

/// 健康分历史导出 — CSV 分享
class ProfileHealthExportService {
  ProfileHealthExportService._();

  /// 导出近 14 天健康分 CSV 并调起系统分享
  static Future<bool> exportAndShare() async {
    try {
      final history = await ProfileHealthHistoryService.load();
      if (history.isEmpty) {
        debugPrint('[ProfileHealthExport] WARN: 无历史数据');
        return false;
      }

      final buffer = StringBuffer()..writeln('日期,健康分');
      final dateFmt = DateFormat('yyyy-MM-dd');
      for (final snap in history) {
        buffer.writeln('${dateFmt.format(snap.date)},${snap.score}');
      }

      final dir = await getTemporaryDirectory();
      final fileName =
          'homestock_health_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '家庭库存健康分历史',
        text: 'HomeStock 健康分趋势导出',
      );
      debugPrint('[ProfileHealthExport] INFO: 已导出 ${history.length} 条');
      return true;
    } catch (e) {
      debugPrint('[ProfileHealthExport] ERROR: 导出失败 $e');
      return false;
    }
  }
}
