/// 搜索页常量 — 热词、占位轮播（物品向）
class SearchConstants {
  SearchConstants._();

  /// 搜索框轮播占位文案
  static const searchPlaceholders = [
    '搜索物品名称、品牌',
    '搜索存放位置',
    '搜索临期、低库存物品',
    '例如：厨房、牛奶、纸巾',
  ];

  /// 热门搜索词（家庭物品场景）
  static const hotKeywords = [
    '临期',
    '低库存',
    '厨房',
    '冰箱',
    '牛奶',
    '过期',
  ];

  /// 空间场景词 — 搜索联动到物品列表位置筛选
  static const spaceKeywords = [
    '厨房',
    '冰箱',
    '卫生间',
    '客厅',
    '卧室',
    '阳台',
    '储物间',
  ];

  static const horizontalPadding = 16.0;
  static const chipSpacing = 8.0;
}
