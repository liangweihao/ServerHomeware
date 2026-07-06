import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shop/shop_daily_sales_builder.dart';
import '../shop/shop_daily_sales_models.dart';
import 'database_provider.dart';
import 'space_skin_provider.dart';

/// 店铺近 7 日简易日销 — 仅 shop 空间有意义
final shopDailySalesProvider =
    FutureProvider<ShopDailySalesSummary>((ref) async {
  final skin = ref.watch(spaceSkinProvider);
  if (!skin.showSalePrice) {
    return ShopDailySalesSummary(
      days: const [],
      totalSellTimes: 0,
      totalSellQuantity: 0,
      totalRevenue: 0,
      pricedSellQuantity: 0,
      totalCost: 0,
      totalGrossProfit: 0,
      costedSellQuantity: 0,
    );
  }

  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final since = DateTime.now().subtract(const Duration(days: 6));
  final dayStart = DateTime(since.year, since.month, since.day);
  final records =
      await db.getUsageRecordsSince(dayStart, type: ShopDailySalesBuilder.usageTypeConsume);
  final items = await db.getAllItems();
  final itemsById = {for (final i in items) i.id: i};

  debugPrint('[shopDailySalesProvider] INFO: 加载近7日卖出记录 ${records.length} 条');
  return ShopDailySalesBuilder.buildSummary(
    records: records,
    itemsById: itemsById,
    now: DateTime.now(),
  );
});

/// 单商品近 7 日卖出
final itemSales7dProvider =
    FutureProvider.family<ItemSales7d, int>((ref, itemId) async {
  final skin = ref.watch(spaceSkinProvider);
  if (!skin.showSalePrice) {
    return const ItemSales7d(
      sellTimes: 0,
      sellQuantity: 0,
      revenue: 0,
      pricedSellQuantity: 0,
      cost: 0,
      grossProfit: 0,
      costedSellQuantity: 0,
    );
  }

  final db = ref.watch(databaseProvider);
  final item = await db.getItemById(itemId);
  if (item == null) {
    return const ItemSales7d(
      sellTimes: 0,
      sellQuantity: 0,
      revenue: 0,
      pricedSellQuantity: 0,
      cost: 0,
      grossProfit: 0,
      costedSellQuantity: 0,
    );
  }

  final since = DateTime.now().subtract(const Duration(days: 6));
  final dayStart = DateTime(since.year, since.month, since.day);
  final records = await db.getUsageRecordsByItemSince(itemId, dayStart);

  return ShopDailySalesBuilder.buildItemSummary(
    records: records,
    salePrice: item.salePrice,
    purchasePrice: item.purchasePrice,
    packageQuantity: item.packageQuantity,
    now: DateTime.now(),
  );
});
