import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/add_item_nl_parser.dart';
import 'package:home_stock/core/assistant/assistant_models.dart';
import 'package:home_stock/core/assistant/assistant_parser.dart';

/// B4 店铺 utterance 单测 — 货架查询 / 断货 / 补货 / 进货 NL
void main() {
  group('AssistantParser shop', () {
    test('店面有什么 — 货架物品查询', () {
      final q = AssistantParser.parse('店面有什么');
      expect(q.intent, AssistantIntentType.querySpaceItems);
      expect(q.spaceName, '店面');
    });

    test('A架有什么 — 货架区域查询', () {
      final q = AssistantParser.parse('A架有什么');
      expect(q.intent, AssistantIntentType.querySpaceItems);
      expect(q.spaceName, 'A架');
    });

    test('红牛还剩多少 — 商品余量查询', () {
      final q = AssistantParser.parse('红牛还剩多少');
      expect(q.intent, AssistantIntentType.queryItemLocation);
      expect(q.itemName, '红牛');
    });

    test('什么快断货 — 低库存/断货查询', () {
      final q = AssistantParser.parse('什么快断货');
      expect(q.intent, AssistantIntentType.queryLowStock);
    });

    test('断货 — 低库存关键词', () {
      final q = AssistantParser.parse('有哪些断货');
      expect(q.intent, AssistantIntentType.queryLowStock);
    });

    test('今天要补什么 — 待补货查询', () {
      final q = AssistantParser.parse('今天要补什么');
      expect(q.intent, AssistantIntentType.queryPending);
    });

    test('库房有什么 — 库房区域查询', () {
      final q = AssistantParser.parse('库房有什么');
      expect(q.intent, AssistantIntentType.querySpaceItems);
      expect(q.spaceName, '库房');
    });
  });

  group('AssistantParser shop addItem', () {
    test('进了10箱可乐放店面 — M5 进货预填', () {
      final q = AssistantParser.parse('进了10箱可乐放店面');
      expect(q.intent, AssistantIntentType.addItem);
      expect(q.addItemDraft?.name, '可乐');
      expect(q.addItemDraft?.quantity, 10);
      expect(q.addItemDraft?.unit, '箱');
      expect(q.addItemDraft?.locationHint, '店面');
    });

    test('AddItemNlParser 进货前缀', () {
      final r = AddItemNlParser.parse('进货2瓶啤酒放冷柜');
      expect(r.isAddIntent, isTrue);
      expect(r.name, '啤酒');
      expect(r.quantity, 2);
      expect(r.unit, '瓶');
      expect(r.locationHint, '冷柜');
    });
  });
}
