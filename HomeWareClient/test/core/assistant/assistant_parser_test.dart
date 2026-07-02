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
  });
}
