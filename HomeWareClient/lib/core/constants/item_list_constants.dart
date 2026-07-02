/// 物品列表分页与滚动加载常量
class ItemListConstants {
  ItemListConstants._();

  /// 列表 Tab（要处理 / 全部）每页条数
  static const int listPageSize = 20;

  /// 网格分组（按空间 / 按分类）每组首批条数
  static const int gridPageSize = 12;

  /// 距底部多少像素时触发加载更多
  static const double loadMoreThreshold = 280;
}
