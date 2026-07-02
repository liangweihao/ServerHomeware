import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/database_provider.dart';
import '../../../core/services/export_service.dart';

/// 数据导出弹窗 — Profile 页复用
class ExportDataDialog {
  ExportDataDialog._();

  static void show(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('数据导出'),
        content: const Text('选择导出范围，生成 CSV 后可分享'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _export(context, ref, ExportScope.all);
            },
            child: const Text('全部物品'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _export(context, ref, ExportScope.inUse);
            },
            child: const Text('仅使用中'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _export(context, ref, ExportScope.expired);
            },
            child: const Text('仅已过期'),
          ),
        ],
      ),
    );
  }

  static Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ExportScope scope,
  ) async {
    try {
      final db = ref.read(databaseProvider);
      final exportService = ExportService(db);
      final filePath = await exportService.exportToCsv(scope);

      if (!context.mounted) return;

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('导出成功'),
            action: SnackBarAction(
              label: '分享',
              onPressed: () => exportService.shareFile(filePath),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可导出的物品')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }
}
