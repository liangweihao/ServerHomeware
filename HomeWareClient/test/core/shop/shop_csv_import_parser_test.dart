import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/shop/shop_csv_import_parser.dart';

void main() {
  group('ShopCsvImportParser', () {
    test('解析标准模板行', () {
      const csv = '''
商品名称,数量,单位,分类,位置,进货单价,售价,品牌,条码
可乐,10,箱,饮料,店面,45,3.5,可口可乐,
红牛,24,罐,饮料,A架,4.5,6,,
''';
      final result = ShopCsvImportParser.parse(csv);
      expect(result.fileError, isNull);
      expect(result.validRows.length, 2);

      final cola = result.validRows.first;
      expect(cola.name, '可乐');
      expect(cola.quantity, 10);
      expect(cola.unit, '箱');
      expect(cola.categoryName, '饮料');
      expect(cola.locationName, '店面');
      expect(cola.purchasePrice, 45);
      expect(cola.salePrice, 3.5);
      expect(cola.brand, '可口可乐');
    });

    test('缺少商品名称列时报错', () {
      const csv = '数量,单位\n1,瓶';
      final result = ShopCsvImportParser.parse(csv);
      expect(result.fileError, isNotNull);
    });

    test('数量无效行标记错误', () {
      const csv = '''
商品名称,数量
测试,abc
''';
      final result = ShopCsvImportParser.parse(csv);
      expect(result.rows.single.parseError, isNotNull);
    });

    test('模板生成含表头与示例', () {
      final text = ShopCsvImportTemplate.buildTemplateCsv();
      expect(text, contains('商品名称'));
      expect(text, contains('可乐'));
    });
  });
}
