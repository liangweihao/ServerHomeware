import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/presentation/items/item_form_controller.dart';

void main() {
  test('预计使用天数计算日均消耗', () {
    final controller = ItemFormController();
    controller.quantity = 10;
    controller.estimatedUseDays = 5;

    final estimate = controller.computeConsumptionEstimate();
    expect(estimate.avgDaily, 2.0);
    expect(estimate.predictedEmpty, isNotNull);
  });

  test('未填写预计天数时不估算', () {
    final controller = ItemFormController();
    controller.quantity = 10;

    final estimate = controller.computeConsumptionEstimate();
    expect(estimate.avgDaily, isNull);
    expect(estimate.predictedEmpty, isNull);
  });
}
