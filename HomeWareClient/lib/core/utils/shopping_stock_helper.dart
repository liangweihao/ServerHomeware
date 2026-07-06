import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import '../config/space_skin_config.dart';

/// 购物清单项对应的家中库存快照 — M4「清单带库存」
class ShoppingStockSnapshot {
  const ShoppingStockSnapshot({
    required this.totalQuantity,
    required this.unit,
    required this.hasMatch,
    required this.matchedItemCount,
    required this.plannedQuantity,
  });

  /// 无匹配时的占位
  const ShoppingStockSnapshot.none({double plannedQuantity = 1})
      : totalQuantity = 0,
        unit = '件',
        hasMatch = false,
        matchedItemCount = 0,
        plannedQuantity = plannedQuantity;

  final double totalQuantity;
  final String unit;
  final bool hasMatch;
  final int matchedItemCount;
  final double plannedQuantity;

  /// 是否可能重复采购（现有量 ≥ 计划购买量）
  bool get isPossiblyRedundant =>
      hasMatch && totalQuantity > 0 && totalQuantity >= plannedQuantity;

  /// 列表展示文案：「现有 2 瓶」/「家里暂无」
  String displayLabel({SpaceSkinConfig? skin}) {
    final cfg = skin ?? SpaceSkinConfig.home;
    if (!hasMatch || totalQuantity <= 0) {
      return cfg.stockNoneLabel;
    }
    return cfg.stockDisplayLabel(quantity: totalQuantity, unit: unit);
  }

  /// 辅助提示（可能不必买）
  String? hintLabel({SpaceSkinConfig? skin}) {
    if (!isPossiblyRedundant) return null;
    return (skin ?? SpaceSkinConfig.home).stockRedundantHint;
  }
}

/// 解析购物项对应的家中库存（relatedItemId 优先，否则按名称匹配）
ShoppingStockSnapshot resolveShoppingStock({
  required ShoppingListData shoppingItem,
  required List<Item> activeItems,
  Item? relatedItem,
}) {
  debugPrint(
    '[ShoppingStockHelper] INFO: 解析库存 listId=${shoppingItem.id} '
    'name=${shoppingItem.name} related=${shoppingItem.relatedItemId}',
  );

  final plannedQty = shoppingItem.quantity;

  // 1. 关联物品 ID（系统推荐 / 从提醒加入）
  if (shoppingItem.relatedItemId != null) {
    final item = relatedItem ??
        _findById(activeItems, shoppingItem.relatedItemId!);
    if (item != null) {
      return ShoppingStockSnapshot(
        totalQuantity: item.currentQuantity,
        unit: item.unit,
        hasMatch: true,
        matchedItemCount: 1,
        plannedQuantity: plannedQty,
      );
    }
  }

  // 2. 名称精确匹配（忽略大小写），合并同名在用物品
  final nameKey = shoppingItem.name.trim().toLowerCase();
  if (nameKey.isEmpty) {
    return ShoppingStockSnapshot.none(plannedQuantity: plannedQty);
  }

  final exactMatches =
      activeItems.where((i) => i.name.trim().toLowerCase() == nameKey).toList();

  if (exactMatches.isNotEmpty) {
    return _aggregate(exactMatches, plannedQty);
  }

  // 3. 名称包含匹配（仅当唯一命中，避免误匹配）
  final containsMatches = activeItems
      .where(
        (i) =>
            i.name.toLowerCase().contains(nameKey) ||
            nameKey.contains(i.name.trim().toLowerCase()),
      )
      .toList();

  if (containsMatches.length == 1) {
    return _aggregate(containsMatches, plannedQty);
  }

  return ShoppingStockSnapshot.none(plannedQuantity: plannedQty);
}

ShoppingStockSnapshot _aggregate(List<Item> items, double plannedQty) {
  final total = items.fold<double>(0, (sum, i) => sum + i.currentQuantity);
  final unit = items.first.unit;
  return ShoppingStockSnapshot(
    totalQuantity: total,
    unit: unit,
    hasMatch: true,
    matchedItemCount: items.length,
    plannedQuantity: plannedQty,
  );
}

Item? _findById(List<Item> items, int id) {
  for (final i in items) {
    if (i.id == id) return i;
  }
  return null;
}

/// 批量解析待购清单库存
Map<int, ShoppingStockSnapshot> resolveShoppingStockMap({
  required List<ShoppingListData> shoppingItems,
  required List<Item> activeItems,
}) {
  final relatedById = {for (final i in activeItems) i.id: i};
  final map = <int, ShoppingStockSnapshot>{};
  for (final s in shoppingItems) {
    Item? related;
    final rid = s.relatedItemId;
    if (rid != null) {
      related = relatedById[rid];
    }
    map[s.id] = resolveShoppingStock(
      shoppingItem: s,
      activeItems: activeItems,
      relatedItem: related,
    );
  }
  return map;
}
