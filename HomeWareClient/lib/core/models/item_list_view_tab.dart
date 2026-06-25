/// 物品列表浏览模式 — 每种 Tab 对应用户「看物品」的不同理由
enum ItemListViewTab {
  /// 需要处理：过期 / 库存不足等
  action,
  /// 按存放空间分组浏览
  space,
  /// 按分类分组浏览
  category,
  /// 全部物品（带出现理由标签）
  all,
}

/// Tab 展示文案
const itemListViewTabLabels = <ItemListViewTab, String>{
  ItemListViewTab.action: '要处理',
  ItemListViewTab.space: '按空间',
  ItemListViewTab.category: '按分类',
  ItemListViewTab.all: '全部',
};

/// Tab emoji
const itemListViewTabEmojis = <ItemListViewTab, String>{
  ItemListViewTab.action: '⚠️',
  ItemListViewTab.space: '📍',
  ItemListViewTab.category: '🏷️',
  ItemListViewTab.all: '📦',
};
