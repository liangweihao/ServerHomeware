import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/events/item_event_bus.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';

/// 可记消耗的物品 — 使用中且剩余 > 0
final quickConsumeItemsProvider = FutureProvider<List<Item>>((ref) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  await db.ensureInitialized();

  final items = await db.getAllItems();
  final candidates = items
      .where((i) => i.status == 0 && i.currentQuantity > 0)
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  debugPrint('[QuickConsume] INFO: 可选 ${candidates.length} 件');
  return candidates;
});
