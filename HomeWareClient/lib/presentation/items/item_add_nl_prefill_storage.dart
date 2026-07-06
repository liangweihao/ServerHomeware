import '../../core/assistant/add_item_nl_parser.dart';

/// M5 NL 预填 — 跨路由暂存解析结果（单次消费）
abstract final class ItemAddNlPrefillStorage {
  static AddItemNlResult? _pending;

  /// 写入待预填数据
  static void save(AddItemNlResult result) {
    _pending = result;
  }

  /// 读取并清除
  static AddItemNlResult? take() {
    final r = _pending;
    _pending = null;
    return r;
  }

  static bool get hasPending => _pending != null;
}
