import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/assistant_parser.dart';
import 'package:home_stock/core/assistant/assistant_models.dart';

void main() {
  group('AssistantParser', () {
    test('识别空间物品查询', () {
      final q = AssistantParser.parse('厨房有什么');
      expect(q.intent, AssistantIntentType.querySpaceItems);
      expect(q.spaceName, '厨房');
    });

    test('识别物品位置查询', () {
      final q = AssistantParser.parse('牛奶在哪');
      expect(q.intent, AssistantIntentType.queryItemLocation);
      expect(q.itemName, '牛奶');
    });

    test('识别还有没有', () {
      final q = AssistantParser.parse('还有牛奶吗');
      expect(q.intent, AssistantIntentType.queryItemLocation);
      expect(q.itemName, '牛奶');
    });

    test('识别临期', () {
      final q = AssistantParser.parse('什么快过期了');
      expect(q.intent, AssistantIntentType.queryExpiring);
    });

    test('识别待处理', () {
      final q = AssistantParser.parse('有什么要处理的');
      expect(q.intent, AssistantIntentType.queryPending);
    });

    test('症状护理诉求走 LLM（unknown）', () {
      final q = AssistantParser.parse('我手有点粗糙');
      expect(q.intent, AssistantIntentType.unknown);
    });

    test('短词物品名仍走本地查询', () {
      final q = AssistantParser.parse('创可贴');
      expect(q.intent, AssistantIntentType.queryItemLocation);
      expect(q.itemName, '创可贴');
    });

    test('做饭诉求走 LLM', () {
      final q = AssistantParser.parse('想吃红烧肉');
      expect(q.intent, AssistantIntentType.unknown);
    });
  });
}
