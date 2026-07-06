import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import 'shop_daily_sales_models.dart';

/// B+ 简易日销 — 纯函数聚合（usage type=1 × sale_price / 进价）
abstract final class ShopDailySalesBuilder {
  static const usageTypeConsume = 1;

  /// 估算基本单位进价：purchase_price / package_quantity
  static double? unitCost(Item item) {
    final price = item.purchasePrice;
    if (price == null || price <= 0) return null;
    final pkgQty = item.packageQuantity;
    if (pkgQty <= 0) return price;
    return price / pkgQty;
  }

  /// 近 [dayCount] 个自然日（含今天）店铺日销
  static ShopDailySalesSummary buildSummary({
    required List<UsageRecord> records,
    required Map<int, Item> itemsById,
    required DateTime now,
    int dayCount = 7,
  }) {
    final today = _dayStart(now);
    final start = today.subtract(Duration(days: dayCount - 1));
    final days = List.generate(dayCount, (i) {
      return DailySalesDay(
        date: start.add(Duration(days: i)),
        sellTimes: 0,
        sellQuantity: 0,
        revenue: 0,
        cost: 0,
        grossProfit: 0,
      );
    });
    final indexByDate = {
      for (var i = 0; i < days.length; i++) days[i].date: i,
    };

    var totalTimes = 0;
    var totalQty = 0.0;
    var totalRevenue = 0.0;
    var pricedQty = 0.0;
    var totalCost = 0.0;
    var totalGrossProfit = 0.0;
    var costedQty = 0.0;

    for (final r in records) {
      if (r.type != usageTypeConsume) continue;
      final day = _dayStart(r.createdAt);
      if (day.isBefore(start) || day.isAfter(today)) continue;

      final idx = indexByDate[day];
      if (idx == null) continue;

      final qty = r.quantity;
      final item = itemsById[r.itemId];
      final unitPrice = item?.salePrice;
      final unitCostValue = item != null ? unitCost(item) : null;

      final lineRevenue =
          unitPrice != null && unitPrice > 0 ? qty * unitPrice : 0.0;
      final lineCost =
          unitCostValue != null && unitCostValue > 0 ? qty * unitCostValue : 0.0;
      final lineProfit = lineRevenue - lineCost;

      final prev = days[idx];
      days[idx] = DailySalesDay(
        date: prev.date,
        sellTimes: prev.sellTimes + 1,
        sellQuantity: prev.sellQuantity + qty,
        revenue: prev.revenue + lineRevenue,
        cost: prev.cost + lineCost,
        grossProfit: prev.grossProfit + lineProfit,
      );

      totalTimes += 1;
      totalQty += qty;
      totalRevenue += lineRevenue;
      totalCost += lineCost;
      totalGrossProfit += lineProfit;
      if (unitPrice != null && unitPrice > 0) {
        pricedQty += qty;
      }
      if (unitCostValue != null && unitCostValue > 0) {
        costedQty += qty;
      }
    }

    debugPrint(
      '[ShopDailySalesBuilder] INFO: 近$dayCount日卖出 $totalTimes 次 '
      'qty=$totalQty revenue=$totalRevenue gross=$totalGrossProfit',
    );

    return ShopDailySalesSummary(
      days: days,
      totalSellTimes: totalTimes,
      totalSellQuantity: totalQty,
      totalRevenue: totalRevenue,
      pricedSellQuantity: pricedQty,
      totalCost: totalCost,
      totalGrossProfit: totalGrossProfit,
      costedSellQuantity: costedQty,
    );
  }

  /// 单商品近 7 日卖出
  static ItemSales7d buildItemSummary({
    required List<UsageRecord> records,
    required double? salePrice,
    required double? purchasePrice,
    required int packageQuantity,
    required DateTime now,
    int dayCount = 7,
  }) {
    final today = _dayStart(now);
    final start = today.subtract(Duration(days: dayCount - 1));

    var times = 0;
    var qty = 0.0;
    var revenue = 0.0;
    var pricedQty = 0.0;
    var cost = 0.0;
    var costedQty = 0.0;
    final hasPrice = salePrice != null && salePrice > 0;
    double? unitCostValue;
    if (purchasePrice != null && purchasePrice > 0) {
      final pkgQty = packageQuantity <= 0 ? 1 : packageQuantity;
      unitCostValue = purchasePrice / pkgQty;
    }
    final hasCost = unitCostValue != null && unitCostValue > 0;

    for (final r in records) {
      if (r.type != usageTypeConsume) continue;
      final day = _dayStart(r.createdAt);
      if (day.isBefore(start) || day.isAfter(today)) continue;

      times += 1;
      qty += r.quantity;
      if (hasPrice) {
        revenue += r.quantity * salePrice;
        pricedQty += r.quantity;
      }
      if (hasCost) {
        cost += r.quantity * unitCostValue;
        costedQty += r.quantity;
      }
    }

    return ItemSales7d(
      sellTimes: times,
      sellQuantity: qty,
      revenue: revenue,
      pricedSellQuantity: pricedQty,
      cost: cost,
      grossProfit: revenue - cost,
      costedSellQuantity: costedQty,
    );
  }

  static DateTime _dayStart(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
