import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

enum TimeRange { week, month, year }

// 时间范围 Provider
final timeRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.month);

// 消费统计数据
class ConsumptionStats {
  final double totalExpense;
  final double? expenseChange;
  final List<MonthlyExpense> monthlyTrend;

  ConsumptionStats({
    required this.totalExpense,
    this.expenseChange,
    required this.monthlyTrend,
  });
}

class MonthlyExpense {
  final DateTime month;
  final double amount;

  MonthlyExpense({required this.month, required this.amount});
}

// 分类统计数据
class CategoryStats {
  final String name;
  final String icon;
  final String color;
  final double amount;
  final double percentage;

  CategoryStats({
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

// 浪费统计数据
class WasteStats {
  final int count;
  final double amount;
  final List<WasteItem> items;

  WasteStats({
    required this.count,
    required this.amount,
    required this.items,
  });
}

class WasteItem {
  final String name;
  final double price;
  final String reason;

  WasteItem({
    required this.name,
    required this.price,
    required this.reason,
  });
}

// 消耗排行数据
class ConsumptionRanking {
  final String name;
  final double quantity;
  final String unit;
  final double amount;

  ConsumptionRanking({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.amount,
  });
}

// 获取时间范围对应的日期
(DateTime, DateTime) getDateRange(TimeRange range) {
  final now = DateTime.now();
  switch (range) {
    case TimeRange.week:
      final start = now.subtract(Duration(days: now.weekday - 1));
      return (DateTime(start.year, start.month, start.day), now);
    case TimeRange.month:
      return (DateTime(now.year, now.month, 1), now);
    case TimeRange.year:
      return (DateTime(now.year, 1, 1), now);
  }
}

// 消费统计 Provider
final consumptionStatsProvider = FutureProvider<ConsumptionStats>((ref) async {
  final range = ref.watch(timeRangeProvider);
  final db = ref.watch(databaseProvider);
  
  final (startDate, endDate) = getDateRange(range);
  
  // 获取时间范围内的物品
  final items = await (db.select(db.items)
        ..where((i) => i.purchaseDate.isBetweenValues(startDate, endDate)))
      .get();
  
  // 计算总消费
  double totalExpense = 0;
  for (final item in items) {
    if (item.purchasePrice != null) {
      totalExpense += item.purchasePrice!;
    }
  }
  
  // 计算上月消费对比
  double? expenseChange;
  final lastMonthStart = DateTime(endDate.year, endDate.month - 1, 1);
  final lastMonthEnd = DateTime(endDate.year, endDate.month, 0, 23, 59, 59);
  
  final lastMonthItems = await (db.select(db.items)
        ..where((i) => i.purchaseDate.isBetweenValues(lastMonthStart, lastMonthEnd)))
      .get();
  
  double lastMonthExpense = 0;
  for (final item in lastMonthItems) {
    if (item.purchasePrice != null) {
      lastMonthExpense += item.purchasePrice!;
    }
  }
  
  if (lastMonthExpense > 0) {
    expenseChange = ((totalExpense - lastMonthExpense) / lastMonthExpense) * 100;
  }
  
  // 获取最近6个月趋势
  final monthlyTrend = <MonthlyExpense>[];
  final now = DateTime.now();
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i, 1);
    final monthEnd = DateTime(now.year, now.month - i + 1, 0, 23, 59, 59);
    
    final monthItems = await (db.select(db.items)
          ..where((item) => item.purchaseDate.isBetweenValues(month, monthEnd)))
        .get();
    
    double monthAmount = 0;
    for (final item in monthItems) {
      if (item.purchasePrice != null) {
        monthAmount += item.purchasePrice!;
      }
    }
    
    monthlyTrend.add(MonthlyExpense(month: month, amount: monthAmount));
  }
  
  return ConsumptionStats(
    totalExpense: totalExpense,
    expenseChange: expenseChange,
    monthlyTrend: monthlyTrend,
  );
});

// 分类统计 Provider
final categoryStatsProvider = FutureProvider<List<CategoryStats>>((ref) async {
  final range = ref.watch(timeRangeProvider);
  final db = ref.watch(databaseProvider);
  
  final (startDate, endDate) = getDateRange(range);
  
  // 获取所有分类
  final categories = await db.getTopLevelCategories();
  
  // 获取时间范围内的物品
  final items = await (db.select(db.items)
        ..where((i) => i.purchaseDate.isBetweenValues(startDate, endDate)))
      .get();
  
  // 计算总金额
  double totalAmount = 0;
  for (final item in items) {
    if (item.purchasePrice != null) {
      totalAmount += item.purchasePrice!;
    }
  }
  
  // 按分类汇总
  final categoryAmounts = <int, double>{};
  for (final item in items) {
    if (item.purchasePrice != null) {
      categoryAmounts[item.categoryId] = 
          (categoryAmounts[item.categoryId] ?? 0) + item.purchasePrice!;
    }
  }
  
  // 构建统计列表
  final stats = <CategoryStats>[];
  for (final category in categories) {
    final amount = categoryAmounts[category.id] ?? 0;
    if (amount > 0) {
      stats.add(CategoryStats(
        name: category.name,
        icon: category.icon,
        color: category.color,
        amount: amount,
        percentage: totalAmount > 0 ? (amount / totalAmount) * 100 : 0,
      ));
    }
  }
  
  // 按金额排序
  stats.sort((a, b) => b.amount.compareTo(a.amount));
  
  return stats;
});

// 浪费统计 Provider
final wasteStatsProvider = FutureProvider<WasteStats>((ref) async {
  final range = ref.watch(timeRangeProvider);
  final db = ref.watch(databaseProvider);
  
  final (startDate, endDate) = getDateRange(range);
  
  // 获取丢弃记录
  final records = await (db.select(db.usageRecords)
        ..where((r) => r.type.equals(2))
        ..where((r) => r.createdAt.isBetweenValues(startDate, endDate)))
      .get();
  
  double totalAmount = 0;
  final wasteItems = <WasteItem>[];
  
  for (final record in records) {
    final item = await db.getItemById(record.itemId);
    if (item != null && item.purchasePrice != null) {
      totalAmount += item.purchasePrice!;
      wasteItems.add(WasteItem(
        name: item.name,
        price: item.purchasePrice!,
        reason: '过期丢弃',
      ));
    }
  }
  
  return WasteStats(
    count: records.length,
    amount: totalAmount,
    items: wasteItems,
  );
});

// 消耗排行 Provider
final consumptionRankingProvider = FutureProvider<List<ConsumptionRanking>>((ref) async {
  final db = ref.watch(databaseProvider);
  
  // 获取所有使用记录
  final records = await (db.select(db.usageRecords)
        ..where((r) => r.type.equals(1))) // 使用记录
      .get();
  
  // 按物品汇总
  final itemConsumption = <int, double>{};
  for (final record in records) {
    itemConsumption[record.itemId] = 
        (itemConsumption[record.itemId] ?? 0) + record.quantity;
  }
  
  // 排序并取前5
  final sorted = itemConsumption.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  final ranking = <ConsumptionRanking>[];
  for (int i = 0; i < sorted.length && i < 5; i++) {
    final itemId = sorted[i].key;
    final quantity = sorted[i].value;
    
    final item = await db.getItemById(itemId);
    if (item != null) {
      ranking.add(ConsumptionRanking(
        name: item.name,
        quantity: quantity,
        unit: item.unit,
        amount: item.purchasePrice != null ? item.purchasePrice! * (quantity / item.purchaseQuantity) : 0,
      ));
    }
  }
  
  return ranking;
});
