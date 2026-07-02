import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/models/home_section.dart';
import 'package:home_stock/presentation/items/widgets/item_card_feed_data.dart';
import 'package:home_stock/data/database/app_database.dart';

void main() {
  group('ItemCardFeedData', () {
    test('fromHomeSection maps tag and location', () {
      const section = HomeSectionItem(
        id: 1,
        name: '牛奶',
        tagLabel: '还剩 2 天',
        tagColor: Color(0xFF8B6914),
        tagBackground: Color(0xFFF5F0E0),
        locationPath: '厨房 › 冰箱',
        previewImage: '/uploads/a.webp',
      );

      final data = ItemCardFeedData.fromHomeSection(section);

      expect(data.id, 1);
      expect(data.name, '牛奶');
      expect(data.tagLabel, '还剩 2 天');
      expect(data.locationPath, '厨房 › 冰箱');
      expect(data.previewImage, '/uploads/a.webp');
    });

    test('fromItem uses list reason and image', () {
      final item = Item(
        id: 2,
        name: '创可贴',
        categoryId: 1,
        purchaseQuantity: 1,
        packageQuantity: 1,
        currentQuantity: 3,
        unit: '盒',
        safetyStock: 1,
        expiryAlertDays: 3,
        stockAlert: true,
        status: 0,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final data = ItemCardFeedData.fromItem(
        item,
        locationName: '卫生间',
      );

      expect(data.name, '创可贴');
      expect(data.locationPath, '卫生间');
      expect(data.tagLabel, isNotEmpty);
    });
  });
}
