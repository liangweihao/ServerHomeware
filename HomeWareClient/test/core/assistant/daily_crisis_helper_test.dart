import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/daily_crisis_helper.dart';
import 'package:home_stock/core/assistant/guanguan_copy.dart';
import 'package:home_stock/core/models/space_type.dart';
import 'package:home_stock/core/providers/home_provider.dart';

void main() {
  group('resolveDailyCrisis', () {
    HomeStats stats({
      int expired = 0,
      int expiring = 0,
      int low = 0,
      String? expiredItem,
      String? expiringItem,
      String? lowItem,
    }) {
      return HomeStats(
        expiredCount: expired,
        expiringCount: expiring,
        lowStockCount: low,
        shoppingCount: 0,
        monthlyExpense: 0,
        latestExpiredItem: expiredItem,
        latestExpiringItem: expiringItem,
        latestLowStockItem: lowItem,
      );
    }

    test('无待处理时返回 null', () {
      expect(resolveDailyCrisis(stats()), isNull);
    });

    test('已过期优先于临期与低库存', () {
      final crisis = resolveDailyCrisis(stats(
        expired: 1,
        expiring: 2,
        low: 3,
        expiredItem: '过期牛奶',
        expiringItem: '酸奶',
        lowItem: '盐',
      ));
      expect(crisis?.kind, DailyCrisisKind.expired);
      expect(crisis?.itemName, '过期牛奶');
      expect(crisis?.totalIssues, 6);
      expect(crisis?.otherIssuesCount, 5);
    });

    test('仅临期时选临期代表物品', () {
      final crisis = resolveDailyCrisis(stats(
        expiring: 2,
        low: 1,
        expiringItem: '豆腐',
        lowItem: '酱油',
      ));
      expect(crisis?.kind, DailyCrisisKind.expiring);
      expect(crisis?.itemName, '豆腐');
    });

    test('仅低库存时选低库存代表物品', () {
      final crisis = resolveDailyCrisis(stats(
        low: 1,
        lowItem: '大米',
      ));
      expect(crisis?.kind, DailyCrisisKind.lowStock);
      expect(crisis?.headline, contains('大米'));
    });

    test('店铺低库存优先于临期与过期', () {
      final crisis = resolveDailyCrisis(
        stats(
          expired: 1,
          expiring: 2,
          low: 3,
          expiredItem: '过期酸奶',
          expiringItem: '临期牛奶',
          lowItem: '红牛',
        ),
        spaceType: SpaceType.shop,
      );
      expect(crisis?.kind, DailyCrisisKind.lowStock);
      expect(crisis?.itemName, '红牛');
      expect(crisis?.totalIssues, 6);
    });

    test('家庭仍保持过期优先', () {
      final crisis = resolveDailyCrisis(
        stats(
          expired: 1,
          expiring: 2,
          low: 3,
          expiredItem: '过期酸奶',
          expiringItem: '临期牛奶',
          lowItem: '红牛',
        ),
        spaceType: SpaceType.home,
      );
      expect(crisis?.kind, DailyCrisisKind.expired);
      expect(crisis?.itemName, '过期酸奶');
    });
  });

  group('GuanguanCopy', () {
    test('庆祝文案包含物品名', () {
      expect(
        GuanguanCopy.celebrateConsume(itemName: '牛奶', depleted: false),
        contains('牛奶'),
      );
    });
  });
}
