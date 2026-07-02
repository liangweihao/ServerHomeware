import '../../data/database/app_database.dart';

/// 物品模型扩展 — 服务端 API 与本地主键解耦
extension ItemApiId on Item {
  /// 调用服务端 API 时使用的 items.id
  int get serverApiId => serverItemId ?? id;
}
