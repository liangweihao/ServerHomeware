import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import 'shop_csv_import_parser.dart';

/// B+ 店铺库存 CSV 导出 — 与进货导入模板表头对齐，便于 Excel 编辑后回导
abstract final class ShopCsvExportService {
  static final _encoder = Csv(lineDelimiter: '\n', addBom: true);

  /// 导出当前库存为进货模板兼容 CSV；无物品时返回 null
  static Future<String?> buildInventoryCsv(AppDatabase db) async {
    final items = await db.getAllItems();
    if (items.isEmpty) {
      debugPrint('[ShopCsvExportService] WARN: 无物品可导出');
      return null;
    }

    final categories = {
      for (final c in await db.getAllCategoriesFlat()) c.id: c.name,
    };
    final locations = {
      for (final l in await db.getAllLocations()) l.id: l.fullPath,
    };

    final rows = <List<String>>[
      ShopCsvImportTemplate.headers,
    ];

    for (final item in items) {
      if (item.status != 0) continue;

      rows.add([
        item.name,
        _formatQty(item.currentQuantity),
        item.unit,
        categories[item.categoryId] ?? '',
        item.locationId != null ? (locations[item.locationId] ?? '') : '',
        item.purchasePrice?.toString() ?? '',
        item.salePrice?.toString() ?? '',
        item.supplier ?? '',
        item.brand ?? '',
        item.barcode ?? '',
      ]);
    }

    if (rows.length <= 1) {
      debugPrint('[ShopCsvExportService] WARN: 无使用中物品');
      return null;
    }

    debugPrint('[ShopCsvExportService] INFO: 导出 ${rows.length - 1} 条');
    return _encoder.encode(rows);
  }

  static String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toString();
  }
}
