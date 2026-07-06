import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/shop/shop_csv_import_parser.dart';

void main() {
  group('ShopCsvExportService', () {
    test('进货/导出模板表头一致且含供应商', () {
      expect(
        ShopCsvImportTemplate.headers,
        [
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
        ],
      );
    });

    test('模板 CSV 可被 Parser 识别', () {
      final csv = ShopCsvImportTemplate.buildTemplateCsv();
      final parsed = ShopCsvImportParser.parse(csv);
      expect(parsed.fileError, isNull);
      expect(parsed.validRows.length, ShopCsvImportTemplate.sampleRows.length);
    });
  });
}
