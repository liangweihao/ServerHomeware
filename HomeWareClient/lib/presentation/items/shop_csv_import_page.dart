import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/space_skin_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/auth/shop_role_guard.dart';
import '../../core/providers/family_role_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../../core/shop/shop_csv_export_service.dart';
import '../../core/shop/shop_csv_import_models.dart';
import '../../core/shop/shop_csv_import_parser.dart';
import '../../core/shop/shop_csv_import_service.dart';
import '../../core/shop/shop_import_lookup.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/warm_scaffold.dart';

/// B+ CSV 批量进货页 — 店铺空间选文件、预览、导入
class ShopCsvImportPage extends ConsumerStatefulWidget {
  const ShopCsvImportPage({super.key});

  @override
  ConsumerState<ShopCsvImportPage> createState() => _ShopCsvImportPageState();
}

class _ShopCsvImportPageState extends ConsumerState<ShopCsvImportPage> {
  ShopCsvParseResult? _parseResult;
  String? _fileName;
  bool _importing = false;
  int _progressDone = 0;
  int _progressTotal = 0;
  ShopCsvImportResult? _importResult;

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    final role = ref.watch(familyRoleProvider);

    if (!ShopRoleGuard.canBulkImport(skin, role)) {
      return WarmScaffold(
        title: skin.csvImportTitle,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'CSV 批量进货需要管理员或老板权限',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return WarmScaffold(
      title: skin.csvImportTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            skin.csvImportSubtitle,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          _buildActionRow(skin),
          const SizedBox(height: 20),
          if (_fileName != null)
            Text(
              '已选：$_fileName',
              style: const TextStyle(fontSize: 13, color: AppColors.textHint),
            ),
          if (_parseResult?.fileError != null) ...[
            const SizedBox(height: 12),
            Text(
              _parseResult!.fileError!,
              style: TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ],
          if (_parseResult != null && _parseResult!.fileError == null) ...[
            const SizedBox(height: 16),
            _buildPreview(_parseResult!),
            const SizedBox(height: 20),
            AppButton(
              label: _importing
                  ? '导入中 $_progressDone/$_progressTotal'
                  : '开始导入 (${_parseResult!.validRows.length} 条)',
              onPressed: _importing || _parseResult!.validRows.isEmpty
                  ? null
                  : _runImport,
            ),
          ],
          if (_importResult != null) ...[
            const SizedBox(height: 20),
            _buildResultCard(_importResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow(SpaceSkinConfig skin) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _importing ? null : _pickCsv,
                icon: const CandyIcon(Icons.upload_file_outlined),
                label: const Text('选择 CSV'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _importing ? null : _shareTemplate,
                icon: const CandyIcon(Icons.description_outlined),
                label: Text(skin.csvTemplateButtonLabel),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _importing ? null : _exportInventory,
            icon: const CandyIcon(Icons.download_outlined),
            label: Text(skin.csvExportButtonLabel),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(ShopCsvParseResult result) {
    final preview = result.rows.take(20).toList();
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              '预览（共 ${result.rows.length} 行，有效 ${result.validRows.length} 行）',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          for (final row in preview)
            ListTile(
              dense: true,
              title: Text(row.name.isEmpty ? '（空）' : row.name),
              subtitle: Text(
                row.isValid
                    ? '${row.quantity}${row.unit} · ${row.categoryName ?? '默认分类'} · ${row.locationName ?? '默认位置'}'
                    : row.parseError ?? '无效',
              ),
              trailing: CandyIcon(
                row.isValid ? Icons.check_circle_outline : Icons.error_outline,
                color: row.isValid ? AppColors.success : AppColors.danger,
                size: 20,
              ),
            ),
          if (result.rows.length > 20)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('… 仅展示前 20 行', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ShopCsvImportResult result) {
    return Material(
      color: AppColors.primaryLighter,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '导入完成：成功 ${result.success} · 失败 ${result.failed} · 跳过 ${result.skipped}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (result.failures.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final f in result.failures.take(5))
                Text(
                  '第${f.lineNumber}行「${f.name}」：${f.message}',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/items'),
              child: const Text('查看物品列表'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCsv() async {
    debugPrint('[ShopCsvImportPage] INFO: 选择 CSV 文件');
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法读取文件内容')),
      );
      return;
    }

    final content = String.fromCharCodes(bytes);
    setState(() {
      _fileName = file.name;
      _parseResult = ShopCsvImportParser.parse(content);
      _importResult = null;
    });
  }

  Future<void> _shareTemplate() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/shop_import_template.csv';
      final file = File(path);
      await file.writeAsString(ShopCsvImportTemplate.buildTemplateCsv());
      await Share.shareXFiles([XFile(path)], text: '店铺进货 CSV 模板');
      debugPrint('[ShopCsvImportPage] INFO: 分享模板 $path');
    } catch (e) {
      debugPrint('[ShopCsvImportPage] ERROR: 模板分享失败 $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('模板生成失败: $e')),
        );
      }
    }
  }

  /// 导出当前库存为进货模板兼容 CSV
  Future<void> _exportInventory() async {
    try {
      final db = ref.read(databaseProvider);
      final csv = await ShopCsvExportService.buildInventoryCsv(db);
      if (!mounted) return;
      if (csv == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有可导出的使用中商品')),
        );
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/shop_inventory_export.csv';
      await File(path).writeAsString(csv);
      await Share.shareXFiles([XFile(path)], text: '店铺库存导出');
      debugPrint('[ShopCsvImportPage] INFO: 导出库存 $path');
    } catch (e) {
      debugPrint('[ShopCsvImportPage] ERROR: 导出失败 $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _runImport() async {
    final parsed = _parseResult;
    if (parsed == null || parsed.validRows.isEmpty) return;

    setState(() {
      _importing = true;
      _progressDone = 0;
      _progressTotal = parsed.validRows.length;
      _importResult = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final lookup = await ShopImportLookup.fromDatabase(db);
      final service = ShopCsvImportService(db: db);
      final result = await service.importRows(
        rows: parsed.rows,
        lookup: lookup,
        onProgress: (done, total) {
          if (mounted) {
            setState(() {
              _progressDone = done;
              _progressTotal = total;
            });
          }
        },
      );

      ref.invalidate(allItemsProvider);
      ref.read(itemEventBusProvider.notifier).notifyUpdated();

      if (mounted) {
        setState(() => _importResult = result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入完成：成功 ${result.success} 条')),
        );
      }
    } catch (e) {
      debugPrint('[ShopCsvImportPage] ERROR: 导入异常 $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }
}
