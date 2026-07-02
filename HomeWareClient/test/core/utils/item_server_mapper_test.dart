import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/utils/item_server_mapper.dart';

void main() {
  test('avgDailyConsumptionFromJson 解析有效值', () {
    final value = ItemServerMapper.avgDailyConsumptionFromJson({
      'avg_daily_consumption': 2.5,
    });
    expect(value.present, isTrue);
    expect(value.value, 2.5);
  });

  test('avgDailyConsumptionFromJson 缺失时为 absent', () {
    final value = ItemServerMapper.avgDailyConsumptionFromJson({});
    expect(value.present, isFalse);
  });

  test('predictedEmptyDateFromJson 解析 ISO 日期', () {
    final value = ItemServerMapper.predictedEmptyDateFromJson({
      'predicted_empty_date': '2026-08-01',
    });
    expect(value.present, isTrue);
    expect(value.value?.year, 2026);
    expect(value.value?.month, 8);
    expect(value.value?.day, 1);
  });
}
