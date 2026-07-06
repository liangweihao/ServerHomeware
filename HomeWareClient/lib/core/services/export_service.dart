import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../data/database/app_database.dart';

enum ExportScope {
  all,
  inUse,
  expired,
}

class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  /// 导出物品数据到 CSV 文件
  Future<String?> exportToCsv(ExportScope scope) async {
    try {
      // 获取物品数据
      List<Item> items;

      switch (scope) {
        case ExportScope.all:
          items = await _db.getAllItems();
          break;
        case ExportScope.inUse:
          items = await (_db.select(_db.items)
                ..where((i) => i.status.equals(0)))
              .get();
          break;
        case ExportScope.expired:
          final now = DateTime.now();
          items = await (_db.select(_db.items)
                ..where((i) => i.status.equals(0))
                ..where((i) => i.expiryDate.isSmallerThanValue(now)))
              .get();
          break;
      }

      if (items.isEmpty) {
        return null;
      }

      // 生成 CSV 内容
      final buffer = StringBuffer();

      // CSV 表头
      buffer.writeln('物品名称,品牌,分类,位置,购买价格,购买数量,当前剩余,单位,购买日期,过期日期,状态');

      // CSV 数据行
      for (final item in items) {
        // 获取分类名称
        final category = await _db.getCategoryById(item.categoryId);
        final categoryName = category?.name ?? '未分类';

        // 获取位置名称
        String locationName = '未设置';
        if (item.locationId != null) {
          final location = await _db.getLocationById(item.locationId!);
          locationName = location?.fullPath ?? '未设置';
        }

        // 格式化状态
        String statusText;
        switch (item.status) {
          case 0:
            statusText = '使用中';
            break;
          case 1:
            statusText = '已用完';
            break;
          case 2:
            statusText = '已丢弃';
            break;
          default:
            statusText = '未知';
        }

        // 格式化日期
        final dateFormat = DateFormat('yyyy-MM-dd');
        final purchaseDate = item.purchaseDate != null
            ? dateFormat.format(item.purchaseDate!)
            : '';
        final expiryDate = item.expiryDate != null
            ? dateFormat.format(item.expiryDate!)
            : '';

        // 转义CSV特殊字符
        String escapeCsvField(String field) {
          if (field.contains(',') || field.contains('"') || field.contains('\n')) {
            return '"${field.replaceAll('"', '""')}"';
          }
          return field;
        }

        buffer.writeln([
          escapeCsvField(item.name),
          escapeCsvField(item.brand ?? ''),
          escapeCsvField(categoryName),
          escapeCsvField(locationName),
          item.purchasePrice?.toString() ?? '',
          item.purchaseQuantity.toString(),
          item.currentQuantity.toString(),
          escapeCsvField(item.unit),
          purchaseDate,
          expiryDate,
          escapeCsvField(statusText),
        ].join(','));
      }

      // 保存到临时文件
      final directory = await getTemporaryDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'homestock_export_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// 分享导出文件
  Future<void> shareFile(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'HomeStock 物品导出',
      );
    } catch (e) {
      // Ignore share errors
    }
  }

  /// 将 CSV 文本写入临时文件并返回路径
  static Future<String> writeCsvToTempFile(
    String csvContent, {
    required String prefix,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${prefix}_$timestamp.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent);
    return file.path;
  }
}
