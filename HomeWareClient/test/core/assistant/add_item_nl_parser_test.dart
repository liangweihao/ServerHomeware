import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/add_item_nl_parser.dart';
import 'package:home_stock/core/assistant/assistant_parser.dart';
import 'package:home_stock/core/assistant/assistant_models.dart';

void main() {
  group('AddItemNlParser', () {
    test('帮我添加牛奶在冰箱', () {
      final r = AddItemNlParser.parse('帮我添加牛奶在冰箱');
      expect(r.isAddIntent, isTrue);
      expect(r.name, '牛奶');
      expect(r.locationHint, '冰箱');
    });

    test('入库2瓶酸奶放厨房', () {
      final r = AddItemNlParser.parse('入库2瓶酸奶放厨房');
      expect(r.name, '酸奶');
      expect(r.quantity, 2);
      expect(r.unit, '瓶');
      expect(r.locationHint, '厨房');
    });

    test('记一笔创可贴', () {
      final r = AddItemNlParser.parse('记一笔创可贴');
      expect(r.name, '创可贴');
      expect(r.locationHint, isNull);
    });

    test('牛奶放冰箱 — 无添加前缀', () {
      final r = AddItemNlParser.parse('牛奶放冰箱');
      expect(r.name, '牛奶');
      expect(r.locationHint, '冰箱');
    });

    test('过期日期', () {
      final r = AddItemNlParser.parse('添加牛奶过期2026-12-01');
      expect(r.name, '牛奶');
      expect(r.expiryDate, DateTime(2026, 12, 1));
    });

    test('查询语句不是入库', () {
      expect(AddItemNlParser.parse('厨房有什么').isAddIntent, isFalse);
      expect(AddItemNlParser.parse('牛奶在哪').isAddIntent, isFalse);
    });

    test('进了10箱可乐放店面 — 店铺进货', () {
      final r = AddItemNlParser.parse('进了10箱可乐放店面');
      expect(r.isAddIntent, isTrue);
      expect(r.name, '可乐');
      expect(r.quantity, 10);
      expect(r.unit, '箱');
      expect(r.locationHint, '店面');
    });
  });

  group('AssistantParser M5', () {
    test('识别添加入库意图', () {
      final q = AssistantParser.parse('帮我添加牛奶在冰箱');
      expect(q.intent, AssistantIntentType.addItem);
      expect(q.addItemDraft?.name, '牛奶');
    });

    test('识别物品位置查询 — 修复在哪解析', () {
      final q = AssistantParser.parse('牛奶在哪');
      expect(q.intent, AssistantIntentType.queryItemLocation);
      expect(q.itemName, '牛奶');
    });
  });
}
