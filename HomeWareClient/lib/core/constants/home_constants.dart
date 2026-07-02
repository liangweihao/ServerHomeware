/// 首页单页布局常量
class HomeConstants {
  HomeConstants._();

  /// 顶栏固定高度（不含 SafeArea）
  static const double appBarHeight = 56;

  /// 横向卡片宽度
  static const double cardWidth = 148;

  /// 卡片场景图高度
  static const double cardImageHeight = 110;

  /// 横向列表容器高度（单行，含阴影）
  static const double horizontalListHeight = 196;

  /// 首页分区预览行数（双排横向滚动）
  static const int previewRowCount = 2;

  /// 双排卡片行间距
  static const double previewRowSpacing = 12;

  /// 双排横向列表容器高度
  static const double twoRowListHeight =
      horizontalListHeight * previewRowCount + previewRowSpacing;

  /// 双排网格列间距（水平方向）
  static const double previewColumnSpacing = 12;

  /// 首页每个分区预览条数
  static const int previewLimit = 10;

  /// 临期天数阈值
  static const int expiringDays = 7;

  /// 页面水平边距
  static const double horizontalPadding = 16;

  /// 模块浅米色背景
  static const sectionBackground = 0xFFF5F0E8;
}
