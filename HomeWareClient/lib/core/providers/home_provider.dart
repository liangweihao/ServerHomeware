import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../events/item_event_bus.dart';
import 'database_provider.dart';

// 首页统计数据
class HomeStats {
  final int expiringCount;
  final int lowStockCount;
  final int shoppingCount;
  final double monthlyExpense;
  final String? latestExpiringItem;
  final String? latestLowStockItem;
  final double? monthlyExpenseChange;

  HomeStats({
    required this.expiringCount,
    required this.lowStockCount,
    required this.shoppingCount,
    required this.monthlyExpense,
    this.latestExpiringItem,
    this.latestLowStockItem,
    this.monthlyExpenseChange,
  });
}

// 首页统计数据 Provider
final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  ref.watch(itemEventBusProvider); // 物品变更时自动刷新统计
  final db = ref.watch(databaseProvider);
  
  await db.ensureInitialized();
  
  // 获取过期预警数量（7天内过期）
  final sevenDaysLater = DateTime.now().add(const Duration(days: 7));
  final expiryItems = await (db.select(db.items)
        ..where((i) => i.status.equals(0))
        ..where((i) => i.expiryDate.isSmallerOrEqualValue(sevenDaysLater))
        ..where((i) => i.expiryDate.isNotNull()))
      .get();
  
  // 获取库存不足数量
  final stockItems = await (db.select(db.items)
        ..where((i) => i.status.equals(0))
        ..where((i) => i.currentQuantity.isSmallerOrEqual(i.safetyStock)))
      .get();
  
  // 获取待购数量
  final shoppingItems = await db.getShoppingList();
  final pendingShoppingCount = shoppingItems.where((s) => !s.isPurchased).length;
  
  // 计算本月消费
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  
  final monthlyItems = await (db.select(db.items)
        ..where((i) => i.purchaseDate.isBetweenValues(monthStart, monthEnd)))
      .get();
  
  double monthlyExpense = 0;
  for (final item in monthlyItems) {
    if (item.purchasePrice != null) {
      monthlyExpense += item.purchasePrice!;
    }
  }
  
  // 计算上月消费（用于对比）
  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
  
  final lastMonthItems = await (db.select(db.items)
        ..where((i) => i.purchaseDate.isBetweenValues(lastMonthStart, lastMonthEnd)))
      .get();
  
  double lastMonthExpense = 0;
  for (final item in lastMonthItems) {
    if (item.purchasePrice != null) {
      lastMonthExpense += item.purchasePrice!;
    }
  }
  
  double? expenseChange;
  if (lastMonthExpense > 0) {
    expenseChange = ((monthlyExpense - lastMonthExpense) / lastMonthExpense) * 100;
  }
  
  // 获取最新过期物品
  String? latestExpiringItem;
  if (expiryItems.isNotEmpty) {
    expiryItems.sort((a, b) {
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });
    latestExpiringItem = expiryItems.first.name;
  }
  
  // 获取最新库存不足物品
  String? latestLowStockItem;
  if (stockItems.isNotEmpty) {
    latestLowStockItem = stockItems.first.name;
  }
  
  return HomeStats(
    expiringCount: expiryItems.length,
    lowStockCount: stockItems.length,
    shoppingCount: pendingShoppingCount,
    monthlyExpense: monthlyExpense,
    latestExpiringItem: latestExpiringItem,
    latestLowStockItem: latestLowStockItem,
    monthlyExpenseChange: expenseChange,
  );
});

// 空间数据（顶级位置 + 物品数）
class SpaceData {
  final Location location;
  final int itemCount;

  SpaceData({required this.location, required this.itemCount});
}

// 空间列表 Provider
final spacesProvider = FutureProvider<List<SpaceData>>((ref) async {
  ref.watch(itemEventBusProvider); // 物品变更时自动刷新空间数据
  final db = ref.watch(databaseProvider);
  
  await db.ensureInitialized();
  
  final locations = await db.getTopLevelLocations();
  final spaces = <SpaceData>[];
  
  for (final location in locations) {
    final count = await db.getItemCountForLocation(location.id);
    spaces.add(SpaceData(location: location, itemCount: count));
  }
  
  return spaces;
});

// 最近动态数据
class ActivityData {
  final String description;
  final DateTime time;
  final int? itemId;

  ActivityData({
    required this.description,
    required this.time,
    this.itemId,
  });
}

// 最近动态 Provider（最近5条）
final recentActivitiesProvider = FutureProvider<List<ActivityData>>((ref) async {
  ref.watch(itemEventBusProvider); // 物品变更时自动刷新动态
  final db = ref.watch(databaseProvider);
  
  await db.ensureInitialized();
  
  final records = await (db.select(db.usageRecords)
        ..orderBy([(r) => OrderingTerm(expression: r.createdAt, mode: OrderingMode.desc)])
        ..limit(5))
      .get();
  
  final activities = <ActivityData>[];
  
  for (final record in records) {
    final item = await db.getItemById(record.itemId);
    if (item == null) continue;
    
    String description;
    switch (record.type) {
      case 0: // 入库
        description = '入库了「${item.name}」';
        break;
      case 1: // 使用
        description = '用完了「${item.name}」';
        break;
      case 2: // 丢弃
        description = '丢弃了「${item.name}」';
        break;
      case 3: // 移动
        description = '移动了「${item.name}」';
        break;
      case 4: // 调整
        description = '调整了「${item.name}」';
        break;
      default:
        description = '操作了「${item.name}」';
    }
    
    activities.add(ActivityData(
      description: description,
      time: record.createdAt,
      itemId: record.itemId,
    ));
  }
  
  return activities;
});
