import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'shop_csv_import_models.dart';

/// B+ CSV 进货模板表头（与导出/模板文件一致）
abstract final class ShopCsvImportTemplate {
  static const headers = [
    '商品名称',
    '数量',
    '单位',
    '分类',
    '位置',
    '进货单价',
    '售价',
    '供应商',
    '品牌',
    '条码',
  ];

  static const sampleRows = [
    ['可乐', '10', '箱', '饮料', '店面', '45', '3.5', '某某批发', '可口可乐', ''],
    ['红牛', '24', '罐', '饮料', 'A架', '4.5', '6', '', '', ''],
  ];

  /// 生成 UTF-8 BOM CSV 模板内容
  static String buildTemplateCsv() {
    final encoder = Csv(lineDelimiter: '\n', addBom: true);
    return encoder.encode([
      headers,
      ...sampleRows,
    ]);
  }
}

/// CSV 解析 — 表头别名映射 + 行校验
abstract final class ShopCsvImportParser {
  static final _csvDecoder = Csv(lineDelimiter: '\n', skipEmptyLines: true);
  static const _fieldAliases = <String, List<String>>{
    'name': ['商品名称', '名称', '物品名称', 'name', '商品'],
    'quantity': ['数量', '进货数量', '购买数量', 'quantity', 'qty'],
    'unit': ['单位', 'unit'],
    'category': ['分类', 'category', '类别'],
    'location': ['位置', '货架', 'location', '存放位置'],
    'purchase_price': ['进货单价', '进价', '购买价格', '单价', 'purchase_price'],
    'sale_price': ['售价', '零售价', 'sale_price'],
    'supplier': ['供应商', '供货商', 'supplier', 'vendor'],
    'brand': ['品牌', 'brand'],
    'barcode': ['条码', 'barcode', '条形码'],
  };

  /// 解析 CSV 文本
  static ShopCsvParseResult parse(String rawContent) {
    var content = rawContent.trim();
    if (content.startsWith('\uFEFF')) {
      content = content.substring(1);
    }
    if (content.isEmpty) {
      return const ShopCsvParseResult(
        rows: [],
        fileError: '文件为空',
      );
    }

    List<List<dynamic>> table;
    try {
      table = _csvDecoder.decode(content);
    } catch (e) {
      debugPrint('[ShopCsvImportParser] ERROR: CSV 解析失败 $e');
      return ShopCsvParseResult(
        rows: const [],
        fileError: 'CSV 格式无法识别',
      );
    }

    if (table.isEmpty) {
      return const ShopCsvParseResult(rows: [], fileError: '没有数据行');
    }

    final headerRow = table.first.map((c) => c.toString().trim()).toList();
    final columnIndex = _mapColumns(headerRow);
    if (!columnIndex.containsKey('name')) {
      return const ShopCsvParseResult(
        rows: [],
        fileError: '缺少「商品名称」列，请使用模板表头',
      );
    }

    final rows = <ShopCsvImportRow>[];
    for (var i = 1; i < table.length; i++) {
      final cells = table[i].map((c) => c.toString().trim()).toList();
      if (cells.every((c) => c.isEmpty)) continue;

      final lineNo = i + 1;
      final name = _cell(cells, columnIndex['name']).trim();
      if (name.isEmpty) {
        rows.add(ShopCsvImportRow(
          lineNumber: lineNo,
          name: '',
          parseError: '商品名称不能为空',
        ));
        continue;
      }

      final qtyRaw = _cell(cells, columnIndex['quantity']);
      final quantity = qtyRaw.isEmpty ? 1.0 : (double.tryParse(qtyRaw) ?? -1);
      if (quantity <= 0) {
        rows.add(ShopCsvImportRow(
          lineNumber: lineNo,
          name: name,
          parseError: '数量无效：$qtyRaw',
        ));
        continue;
      }

      final purchaseRaw = _cell(cells, columnIndex['purchase_price']);
      final saleRaw = _cell(cells, columnIndex['sale_price']);

      rows.add(ShopCsvImportRow(
        lineNumber: lineNo,
        name: name,
        quantity: quantity,
        unit: _cell(cells, columnIndex['unit']).isEmpty
            ? '件'
            : _cell(cells, columnIndex['unit']),
        categoryName: _optionalCell(cells, columnIndex['category']),
        locationName: _optionalCell(cells, columnIndex['location']),
        purchasePrice: _parsePrice(purchaseRaw),
        salePrice: _parsePrice(saleRaw),
        supplier: _optionalCell(cells, columnIndex['supplier']),
        brand: _optionalCell(cells, columnIndex['brand']),
        barcode: _optionalCell(cells, columnIndex['barcode']),
      ));
    }

    debugPrint('[ShopCsvImportParser] INFO: 解析 ${rows.length} 行');
    return ShopCsvParseResult(rows: rows);
  }

  static Map<String, int> _mapColumns(List<String> headers) {
    final normalized = headers.map((h) => h.trim().toLowerCase()).toList();
    final result = <String, int>{};

    for (final entry in _fieldAliases.entries) {
      for (var i = 0; i < normalized.length; i++) {
        final h = normalized[i];
        if (entry.value.any((alias) => alias.toLowerCase() == h)) {
          result[entry.key] = i;
          break;
        }
      }
    }
    return result;
  }

  static String _cell(List<String> cells, int? index) {
    if (index == null || index < 0 || index >= cells.length) return '';
    return cells[index];
  }

  static String? _optionalCell(List<String> cells, int? index) {
    final v = _cell(cells, index).trim();
    return v.isEmpty ? null : v;
  }

  static double? _parsePrice(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return null;
    return double.tryParse(v.replaceAll('¥', '').replaceAll(',', ''));
  }
}
