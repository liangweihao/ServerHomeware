import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';

/// Phase B B3 — 店铺默认分类与位置 seed 数据
abstract final class SpaceShopSeedData {
  /// 店铺顶级分类
  static List<CategoriesCompanion> categoryCompanions() {
    return [
      CategoriesCompanion.insert(
        name: '烟酒百货',
        icon: '🚬',
        color: '#8D6E63',
        isSystem: const Value(true),
        sortOrder: const Value(1),
      ),
      CategoriesCompanion.insert(
        name: '饮料',
        icon: '🥤',
        color: '#42A5F5',
        isSystem: const Value(true),
        sortOrder: const Value(2),
      ),
      CategoriesCompanion.insert(
        name: '休闲食品',
        icon: '🍿',
        color: '#FFA726',
        isSystem: const Value(true),
        sortOrder: const Value(3),
      ),
      CategoriesCompanion.insert(
        name: '日用洗护',
        icon: '🧴',
        color: '#4DB6AC',
        isSystem: const Value(true),
        sortOrder: const Value(4),
      ),
      CategoriesCompanion.insert(
        name: '其他',
        icon: '📦',
        color: '#A1887F',
        isSystem: const Value(true),
        sortOrder: const Value(99),
      ),
    ];
  }

  /// 店铺位置树 — 插入顺序决定自增 id（1=店面, 2=库房, 3=柜台, 4-6=店面子架）
  static List<LocationsCompanion> locationCompanions() {
    return [
      LocationsCompanion.insert(
        name: '店面',
        icon: const Value('🏪'),
        level: const Value(1),
        fullPath: '店面',
        sortOrder: const Value(1),
      ),
      LocationsCompanion.insert(
        name: '库房',
        icon: const Value('📦'),
        level: const Value(1),
        fullPath: '库房',
        sortOrder: const Value(2),
      ),
      LocationsCompanion.insert(
        name: '柜台',
        icon: const Value('🧾'),
        level: const Value(1),
        fullPath: '柜台',
        sortOrder: const Value(3),
      ),
      LocationsCompanion.insert(
        name: 'A架',
        icon: const Value('🅰️'),
        parentId: const Value(1),
        level: const Value(2),
        fullPath: '店面/A架',
        sortOrder: const Value(1),
      ),
      LocationsCompanion.insert(
        name: 'B架',
        icon: const Value('🅱️'),
        parentId: const Value(1),
        level: const Value(2),
        fullPath: '店面/B架',
        sortOrder: const Value(2),
      ),
      LocationsCompanion.insert(
        name: '冷柜',
        icon: const Value('🧊'),
        parentId: const Value(1),
        level: const Value(2),
        fullPath: '店面/冷柜',
        sortOrder: const Value(3),
      ),
    ];
  }

  /// 店铺模板标记分类名
  static const markerCategoryName = '烟酒百货';
}
