import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/utils/search_utils.dart';
import 'package:home_stock/data/database/app_database.dart';

Item _item({
  required int id,
  required String name,
  String? brand,
  int? locationId,
}) {
  return Item(
    id: id,
    name: name,
    brand: brand,
    categoryId: 1,
    locationId: locationId,
    purchaseQuantity: 1,
    packageQuantity: 1,
    currentQuantity: 1,
    unit: '件',
    safetyStock: 1,
    expiryAlertDays: 3,
    stockAlert: true,
    status: 0,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('filterItemsByQuery', () {
    final items = [
      _item(id: 1, name: '牛奶', brand: '蒙牛', locationId: 10),
      _item(id: 2, name: '纸巾', locationId: 11),
      _item(id: 3, name: '创可贴'),
    ];

    final locationNames = {
      1: '厨房 › 冰箱',
      2: '卫生间',
    };

    test('matches name', () {
      final results = filterItemsByQuery(
        items: items,
        locationNameByItemId: locationNames,
        query: '牛奶',
      );
      expect(results.length, 1);
      expect(results.first.item.name, '牛奶');
      expect(results.first.nameMatch, isTrue);
    });

    test('matches location path', () {
      final results = filterItemsByQuery(
        items: items,
        locationNameByItemId: locationNames,
        query: '厨房',
      );
      expect(results.length, 1);
      expect(results.first.item.id, 1);
    });

    test('empty query returns empty', () {
      expect(
        filterItemsByQuery(
          items: items,
          locationNameByItemId: locationNames,
          query: '  ',
        ),
        isEmpty,
      );
    });
  });

  group('buildSearchSuggestions', () {
    test('returns matching names limited', () {
      final items = [
        _item(id: 1, name: '牛奶'),
        _item(id: 2, name: '牛奶糖'),
        _item(id: 3, name: '面包'),
      ];
      final suggestions = buildSearchSuggestions(
        items: items,
        query: '牛',
        limit: 5,
      );
      expect(suggestions, contains('牛奶'));
      expect(suggestions, contains('牛奶糖'));
      expect(suggestions, isNot(contains('面包')));
    });
  });
}
