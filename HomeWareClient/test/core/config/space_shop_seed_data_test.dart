import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/config/space_shop_seed_data.dart';

void main() {
  group('SpaceShopSeedData', () {
    test('分类含烟酒百货等 5 项', () {
      final cats = SpaceShopSeedData.categoryCompanions();
      expect(cats.length, 5);
      expect(
        cats.map((c) => c.name.value),
        contains('烟酒百货'),
      );
      expect(cats.map((c) => c.name.value), contains('饮料'));
    });

    test('位置含店面与 A架/B架/冷柜', () {
      final locs = SpaceShopSeedData.locationCompanions();
      final names = locs.map((l) => l.name.value).toList();
      expect(names, containsAll(['店面', '库房', '柜台', 'A架', 'B架', '冷柜']));
    });

    test('店面子位置 parentId 指向店面', () {
      final locs = SpaceShopSeedData.locationCompanions();
      final shelves = locs.where((l) => l.name.value == 'A架').first;
      expect(shelves.parentId.value, 1);
      expect(shelves.fullPath.value, '店面/A架');
    });
  });
}
