import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import '../services/item_deleted_registry.dart';
import '../services/item_service.dart';
import '../services/item_sync_service.dart';

/// 路由参数 id → 本地 Drift 主键（兼容首页/API 传入的服务端 items.id）
class ItemRouteResolver {
  ItemRouteResolver._();

  /// 将 `/items/:id` 中的 id 解析为本地 itemId
  static Future<int?> resolveLocalId(AppDatabase db, int routeId) async {
    if (routeId <= 0) return null;

    await db.ensureInitialized();

    if (await db.getItemById(routeId) != null) {
      return routeId;
    }

    final mapped = await db.getItemByServerItemId(routeId);
    if (mapped != null) {
      debugPrint(
        '[ItemRouteResolver] INFO: serverItemId=$routeId → localId=${mapped.id}',
      );
      return mapped.id;
    }

    // 路由 id 可能直接是服务端 items.id（首页「全部」来自 API）
    if (await ItemDeletedRegistry.isDeleted(routeId)) {
      final remote = await ItemService().getItemDetail(itemId: routeId);
      if (remote.code == 200 && remote.data != null) {
        await ItemDeletedRegistry.unmark(routeId);
        debugPrint(
          '[ItemRouteResolver] INFO: 用户打开已删物品，解除登记 serverId=$routeId',
        );
      } else {
        debugPrint(
          '[ItemRouteResolver] WARN: 已删除且服务端不存在 serverId=$routeId',
        );
        return null;
      }
    }

    final pulled = await ItemSyncService(db).ensureLocalByServerId(routeId);
    if (pulled != null) {
      debugPrint(
        '[ItemRouteResolver] INFO: 拉取入库 serverId=$routeId → localId=$pulled',
      );
    }
    return pulled;
  }
}
