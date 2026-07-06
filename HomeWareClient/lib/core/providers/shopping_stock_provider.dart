import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../events/item_event_bus.dart';
import '../utils/shopping_stock_helper.dart';
import 'database_provider.dart';
import 'shopping_provider.dart';

/// 待购清单每项的家中库存快照 — key 为 shoppingList.id
final pendingShoppingStockProvider =
    FutureProvider<Map<int, ShoppingStockSnapshot>>((ref) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final pending = await ref.watch(pendingShoppingItemsProvider.future);
  final allItems = await db.getAllItems();
  final active = allItems.where((i) => i.status == 0).toList();

  final map = resolveShoppingStockMap(
    shoppingItems: pending,
    activeItems: active,
  );
  debugPrint('[pendingShoppingStockProvider] INFO: 已解析 ${map.length} 项库存');
  return map;
});

/// 待购项中「家里还有货」的数量 — 用于顶部提示条
final shoppingRedundantCountProvider = FutureProvider<int>((ref) async {
  final stockMap = await ref.watch(pendingShoppingStockProvider.future);
  return stockMap.values.where((s) => s.isPossiblyRedundant).length;
});
