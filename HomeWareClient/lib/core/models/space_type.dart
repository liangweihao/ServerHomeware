/// Phase B — 空间类型（与后端 families.space_type 对齐）
enum SpaceType {
  /// 家庭物品管理（默认）
  home,

  /// 小店铺 / 轻量库存
  shop;

  /// API / SharedPreferences 字符串解析
  static SpaceType parse(String? raw) {
    switch (raw?.trim().toLowerCase()) {
      case 'shop':
        return SpaceType.shop;
      case 'home':
      default:
        return SpaceType.home;
    }
  }

  /// 提交创建家庭 API 时使用
  String get apiValue => name;
}
