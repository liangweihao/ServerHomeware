// B+ CSV 批量进货 — 解析行与导入结果

/// 单行进货数据（解析后）
class ShopCsvImportRow {
  const ShopCsvImportRow({
    required this.lineNumber,
    required this.name,
    this.quantity = 1,
    this.unit = '件',
    this.categoryName,
    this.locationName,
    this.purchasePrice,
    this.salePrice,
    this.supplier,
    this.brand,
    this.barcode,
    this.parseError,
  });

  final int lineNumber;
  final String name;
  final double quantity;
  final String unit;
  final String? categoryName;
  final String? locationName;
  final double? purchasePrice;
  final double? salePrice;
  final String? supplier;
  final String? brand;
  final String? barcode;

  /// 非空表示本行无法导入
  final String? parseError;

  bool get isValid => parseError == null && name.trim().isNotEmpty;
}

/// CSV 解析结果
class ShopCsvParseResult {
  const ShopCsvParseResult({
    required this.rows,
    this.fileError,
  });

  final List<ShopCsvImportRow> rows;
  final String? fileError;

  List<ShopCsvImportRow> get validRows =>
      rows.where((r) => r.isValid).toList();
}

/// 单行导入失败详情
class ShopCsvImportFailure {
  const ShopCsvImportFailure({
    required this.lineNumber,
    required this.name,
    required this.message,
  });

  final int lineNumber;
  final String name;
  final String message;
}

/// 批量导入汇总
class ShopCsvImportResult {
  const ShopCsvImportResult({
    required this.total,
    required this.success,
    required this.skipped,
    required this.failures,
  });

  final int total;
  final int success;
  final int skipped;
  final List<ShopCsvImportFailure> failures;

  int get failed => failures.length;
}
