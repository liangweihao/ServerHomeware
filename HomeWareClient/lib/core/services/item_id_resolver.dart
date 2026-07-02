import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';

/// 本地物品 id 与服务端 items.id 映射解析
class ItemIdResolver {
  final AppDatabase _db;

  ItemIdResolver(this._db);

  /// 本地主键 → 服务端 item_id
  Future<int?> toServerId(int localItemId) => _db.resolveServerItemId(localItemId);

  /// 服务端 item_id → 本地主键
  Future<int?> toLocalId(int serverItemId) => _db.resolveLocalItemId(serverItemId);

  /// 创建/同步成功后绑定映射
  Future<void> bind({
    required int localItemId,
    required int serverItemId,
  }) async {
    if (localItemId == serverItemId) {
      await _db.ensureItemServerItemId(localItemId, serverItemId);
      return;
    }
    await _db.setItemServerItemId(localItemId, serverItemId);
    debugPrint(
      '[ItemIdResolver] INFO: 绑定映射 local=$localItemId server=$serverItemId',
    );
  }
}
