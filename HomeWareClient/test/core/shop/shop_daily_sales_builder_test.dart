import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/shop/shop_daily_sales_builder.dart';
import 'package:home_stock/data/database/app_database.dart';

void main() {
  final now = DateTime(2026, 7, 6, 15, 0);

  Item item({
    required int id,
    double? salePrice,
    double? purchasePrice,
    int packageQuantity = 1,
  }) {
    return Item(
      id: id,
      name: '商品$id',
      categoryId: 1,
      purchaseQuantity: 1,
      packageQuantity: packageQuantity,
      currentQuantity: 10,
      unit: '瓶',
      safetyStock: 1,
      expiryAlertDays: 3,
      stockAlert: true,
      status: 0,
      salePrice: salePrice,
      purchasePrice: purchasePrice,
      createdAt: now,
      updatedAt: now,
    );
  }

  UsageRecord usage({
    required int id,
    required int itemId,
    required double quantity,
    required DateTime createdAt,
    int type = 1,
  }) {
    return UsageRecord(
      id: id,
      itemId: itemId,
      type: type,
      quantity: quantity,
      remainingQuantity: 5,
      createdAt: createdAt,
    );
  }

  group('ShopDailySalesBuilder', () {
    test('汇总近7日卖出次数、营业额与毛利', () {
      final summary = ShopDailySalesBuilder.buildSummary(
        records: [
          usage(
            id: 1,
            itemId: 10,
            quantity: 2,
            createdAt: DateTime(2026, 7, 6, 10),
          ),
          usage(
            id: 2,
            itemId: 11,
            quantity: 1,
            createdAt: DateTime(2026, 7, 5, 10),
          ),
          usage(
            id: 3,
            itemId: 10,
            quantity: 1,
            createdAt: DateTime(2026, 6, 28, 10),
          ),
        ],
        itemsById: {
          10: item(id: 10, salePrice: 3.5, purchasePrice: 2.0, packageQuantity: 1),
          11: item(id: 11, salePrice: 5, purchasePrice: 3.0, packageQuantity: 1),
        },
        now: now,
      );

      expect(summary.days.length, 7);
      expect(summary.totalSellTimes, 2);
      expect(summary.totalSellQuantity, 3);
      expect(summary.totalRevenue, closeTo(2 * 3.5 + 5, 0.001));
      expect(summary.totalCost, closeTo(2 * 2 + 3, 0.001));
      expect(summary.totalGrossProfit, closeTo(summary.totalRevenue - summary.totalCost, 0.001));
      expect(summary.revenueIsComplete, isTrue);
      expect(summary.costIsComplete, isTrue);
    });

    test('无售价时营业额为0且标记不完整', () {
      final summary = ShopDailySalesBuilder.buildSummary(
        records: [
          usage(
            id: 1,
            itemId: 10,
            quantity: 2,
            createdAt: DateTime(2026, 7, 6, 10),
          ),
        ],
        itemsById: {10: item(id: 10, purchasePrice: 2)},
        now: now,
      );

      expect(summary.totalSellTimes, 1);
      expect(summary.totalRevenue, 0);
      expect(summary.totalCost, closeTo(4, 0.001));
      expect(summary.revenueIsComplete, isFalse);
      expect(summary.costIsComplete, isTrue);
    });

    test('单商品近7日卖出含毛利', () {
      final itemSales = ShopDailySalesBuilder.buildItemSummary(
        records: [
          usage(
            id: 1,
            itemId: 10,
            quantity: 3,
            createdAt: DateTime(2026, 7, 4, 9),
          ),
        ],
        salePrice: 4,
        purchasePrice: 2,
        packageQuantity: 1,
        now: now,
      );

      expect(itemSales.sellTimes, 1);
      expect(itemSales.sellQuantity, 3);
      expect(itemSales.revenue, 12);
      expect(itemSales.cost, 6);
      expect(itemSales.grossProfit, 6);
    });

    test('基本单位进价按 package_quantity 折算', () {
      expect(
        ShopDailySalesBuilder.unitCost(
          item(id: 1, purchasePrice: 12, packageQuantity: 6),
        ),
        closeTo(2, 0.001),
      );
    });
  });
}
