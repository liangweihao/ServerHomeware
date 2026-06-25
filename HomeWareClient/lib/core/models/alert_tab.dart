/// 提醒中心 Tab 筛选
enum AlertTab { all, expiry, stock, restock, warranty }

const alertTabLabels = {
  AlertTab.all: '全部',
  AlertTab.expiry: '过期',
  AlertTab.stock: '库存',
  AlertTab.restock: '补购',
  AlertTab.warranty: '其他',
};

const alertTabEmojis = {
  AlertTab.all: '📋',
  AlertTab.expiry: '⏰',
  AlertTab.stock: '📦',
  AlertTab.restock: '🛒',
  AlertTab.warranty: '📄',
};
