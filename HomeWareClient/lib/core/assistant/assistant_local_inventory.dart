import 'package:flutter/foundation.dart' show debugPrint;

import '../services/item_enrich_service.dart';
import '../../data/database/app_database.dart';

/// 问管管 — 从本地 Drift 构建库存快照，供 LLM 查询（服务端 DB 未同步时的兜底）
class AssistantLocalInventory {
  AssistantLocalInventory._();

  /// 单次最多上传条数，避免请求体过大
  static const maxItems = 300;

  /// 构建 [{name, quantity, unit, location}] 列表
  static Future<List<Map<String, dynamic>>> buildSnapshot(AppDatabase db) async {
    await db.ensureInitialized();
    final allItems = await db.getAllItems();
    // 仅上传有效库存：未删除且数量大于 0，避免 LLM 误报已用完/幽灵物品
    final active = allItems
        .where((i) => i.status == 0 && i.currentQuantity > 0)
        .toList();
    final locations = await db.getAllLocations();
    final pathById = {for (final l in locations) l.id: l.fullPath};

    final slice = active.length > maxItems ? active.sublist(0, maxItems) : active;
    final snapshot = slice
        .map(
          (i) => {
            'local_id': i.id,
            'server_item_id': i.serverItemId,
            'name': i.name,
            'search_aliases':
                ItemEnrichService.decodeAliases(i.searchAliases),
            'quantity': i.currentQuantity,
            'unit': i.unit,
            'location': i.locationId != null
                ? (pathById[i.locationId] ?? '未指定位置')
                : '未指定位置',
          },
        )
        .toList();

    debugPrint(
      '[AssistantLocalInventory] INFO: 库存快照 active=${active.length} '
      'upload=${snapshot.length}',
    );
    // 便于排查「想吃肉」类误报：打印快照中含「肉」的品名
    final meatLike = snapshot
        .where((e) => (e['name'] as String).contains('肉'))
        .map((e) => '${e['name']}×${e['quantity']}')
        .toList();
    if (meatLike.isNotEmpty) {
      debugPrint(
        '[AssistantLocalInventory] INFO: 快照含「肉」品名 meatLike=$meatLike',
      );
    }
    return snapshot;
  }
}
