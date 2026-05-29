/// 物品变更类型
enum ItemChangeType {
  /// 新增物品
  created,

  /// 更新物品（编辑、状态变更、位置变更、使用记录等）
  updated,

  /// 删除物品
  deleted,
}

/// 物品变更事件
class ItemChangeEvent {
  /// 变更类型
  final ItemChangeType type;

  /// 变更的物品 ID（可为 null 表示批量变更）
  final int? itemId;

  const ItemChangeEvent({
    required this.type,
    this.itemId,
  });

  @override
  String toString() => 'ItemChangeEvent(type: $type, itemId: $itemId)';
}
