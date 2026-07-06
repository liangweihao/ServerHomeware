/// B+ 简易日销 — 单日卖出汇总
class DailySalesDay {
  const DailySalesDay({
    required this.date,
    required this.sellTimes,
    required this.sellQuantity,
    required this.revenue,
    required this.cost,
    required this.grossProfit,
  });

  /// 自然日（本地时区 0 点）
  final DateTime date;

  /// 卖出操作次数（usage type=1 条数）
  final int sellTimes;

  /// 售出基本单位合计
  final double sellQuantity;

  /// 营业额（quantity × sale_price，无售价计 0）
  final double revenue;

  /// 售出成本（quantity × 基本单位进价，无进价计 0）
  final double cost;

  /// 毛利（revenue - cost）
  final double grossProfit;
}

/// 近 N 日店铺日销汇总
class ShopDailySalesSummary {
  const ShopDailySalesSummary({
    required this.days,
    required this.totalSellTimes,
    required this.totalSellQuantity,
    required this.totalRevenue,
    required this.pricedSellQuantity,
    required this.totalCost,
    required this.totalGrossProfit,
    required this.costedSellQuantity,
  });

  /// 按日期升序（共 7 天）
  final List<DailySalesDay> days;
  final int totalSellTimes;
  final double totalSellQuantity;
  final double totalRevenue;

  /// 有售价的售出数量 — 用于提示营业额不完整
  final double pricedSellQuantity;

  /// 有进价可估算成本的售出数量
  final double costedSellQuantity;

  /// 售出成本合计
  final double totalCost;

  /// 毛利合计
  final double totalGrossProfit;

  bool get hasSales => totalSellTimes > 0;

  /// 营业额是否覆盖全部售出量
  bool get revenueIsComplete =>
      totalSellQuantity <= 0 || pricedSellQuantity >= totalSellQuantity;

  /// 成本是否覆盖全部售出量
  bool get costIsComplete =>
      totalSellQuantity <= 0 || costedSellQuantity >= totalSellQuantity;
}

/// 单商品近 7 日卖出
class ItemSales7d {
  const ItemSales7d({
    required this.sellTimes,
    required this.sellQuantity,
    required this.revenue,
    required this.pricedSellQuantity,
    required this.cost,
    required this.grossProfit,
    required this.costedSellQuantity,
  });

  final int sellTimes;
  final double sellQuantity;
  final double revenue;
  final double pricedSellQuantity;
  final double cost;
  final double grossProfit;
  final double costedSellQuantity;

  bool get hasSales => sellTimes > 0;

  bool get revenueIsComplete =>
      sellQuantity <= 0 || pricedSellQuantity >= sellQuantity;

  bool get costIsComplete =>
      sellQuantity <= 0 || costedSellQuantity >= sellQuantity;
}
