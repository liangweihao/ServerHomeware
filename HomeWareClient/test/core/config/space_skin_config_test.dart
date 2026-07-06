import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/guanguan_copy.dart';
import 'package:home_stock/core/config/space_skin_config.dart';
import 'package:home_stock/core/models/space_type.dart';

void main() {
  group('SpaceType', () {
    test('parse shop', () {
      expect(SpaceType.parse('shop'), SpaceType.shop);
    });

    test('未知值回退 home', () {
      expect(SpaceType.parse(null), SpaceType.home);
      expect(SpaceType.parse('invalid'), SpaceType.home);
    });
  });

  group('SpaceSkinConfig', () {
    test('home 与 shop 文案不同', () {
      expect(SpaceSkinConfig.home.createButtonLabel, '创建家庭');
      expect(SpaceSkinConfig.shop.createButtonLabel, '创建店铺');
      expect(SpaceSkinConfig.home.consumeQuickLabel(), '用了 1 件');
      expect(SpaceSkinConfig.shop.consumeQuickLabel(), '卖出 1 件');
      expect(SpaceSkinConfig.home.shoppingListLabel, '购物清单');
      expect(SpaceSkinConfig.shop.shoppingListLabel, '采购清单');
    });

    test('forType 映射正确', () {
      expect(SpaceSkinConfig.forType(SpaceType.shop).orgLabel, '店铺');
    });

    test('shop 危机与庆祝文案', () {
      const skin = SpaceSkinConfig.shop;
      expect(
        skin.dailyCrisisHeadline(
          itemName: '可乐',
          kind: DailyCrisisKind.lowStock,
        ),
        contains('快断货'),
      );
      expect(
        skin.celebrateConsume(itemName: '可乐', depleted: false),
        contains('卖出'),
      );
      expect(skin.stockNoneLabel, '店里暂无');
      expect(skin.showSalePrice, isTrue);
      expect(
        skin.formatSalePrice(salePrice: 3.5, unit: '瓶'),
        '¥3.50/瓶',
      );
      expect(skin.purchasePriceLabel, '进货单价');
      expect(
        skin.dailySalesHeadline(sellTimes: 5, totalRevenue: 20, revenueComplete: true),
        contains('卖出 5 次'),
      );
    });

    test('home 不展示售价字段', () {
      const skin = SpaceSkinConfig.home;
      expect(skin.showSalePrice, isFalse);
      expect(skin.formatSalePrice(salePrice: null, unit: '件'), '—');
    });

    test('home 危机文案保持 Phase A', () {
      const skin = SpaceSkinConfig.home;
      expect(
        skin.dailyCrisisHeadline(
          itemName: '牛奶',
          kind: DailyCrisisKind.expiring,
        ),
        contains('快过期'),
      );
    });
  });
}
