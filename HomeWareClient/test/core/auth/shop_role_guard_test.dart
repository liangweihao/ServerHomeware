import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/auth/shop_role_guard.dart';
import 'package:home_stock/core/config/space_skin_config.dart';

void main() {
  group('ShopRoleGuard', () {
    test('店员不可 bulk 与改价', () {
      expect(
        ShopRoleGuard.canBulkImport(SpaceSkinConfig.shop, 'clerk'),
        isFalse,
      );
      expect(
        ShopRoleGuard.canEditPrice(SpaceSkinConfig.shop, 'clerk'),
        isFalse,
      );
      expect(
        ShopRoleGuard.canDeleteItem(SpaceSkinConfig.shop, 'clerk'),
        isFalse,
      );
    });

    test('管理员可 bulk', () {
      expect(
        ShopRoleGuard.canBulkImport(SpaceSkinConfig.shop, 'admin'),
        isTrue,
      );
    });

    test('home 空间不限制 member', () {
      expect(
        ShopRoleGuard.canBulkImport(SpaceSkinConfig.home, 'member'),
        isTrue,
      );
    });

    test('角色文案', () {
      expect(
        ShopRoleGuard.roleLabel('clerk', isShop: true),
        '店员',
      );
    });
  });
}
