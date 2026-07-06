import 'package:flutter/foundation.dart' show debugPrint;

import '../config/space_skin_config.dart';

/// 店铺成员角色 — 对应服务端 family_members.role
enum ShopFamilyRole {
  owner,
  admin,
  clerk,
  member,
  unknown,
}

/// B+ 店员角色 UI/API 守卫 — 仅 shop 空间生效
abstract final class ShopRoleGuard {
  static ShopFamilyRole parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return ShopFamilyRole.owner;
      case 'admin':
        return ShopFamilyRole.admin;
      case 'clerk':
        return ShopFamilyRole.clerk;
      case 'member':
        return ShopFamilyRole.member;
      default:
        return ShopFamilyRole.unknown;
    }
  }

  static bool _isShop(SpaceSkinConfig skin) => skin.showSalePrice;

  static bool isClerk(SpaceSkinConfig skin, String? role) =>
      _isShop(skin) && parseRole(role) == ShopFamilyRole.clerk;

  /// CSV 批量进货 — admin+
  static bool canBulkImport(SpaceSkinConfig skin, String? role) {
    if (!_isShop(skin)) return true;
    final r = parseRole(role);
    return r == ShopFamilyRole.owner || r == ShopFamilyRole.admin;
  }

  /// 改价/进价/供应商 — admin+
  static bool canEditPrice(SpaceSkinConfig skin, String? role) {
    if (!_isShop(skin)) return true;
    final r = parseRole(role);
    return r == ShopFamilyRole.owner || r == ShopFamilyRole.admin;
  }

  /// 删除物品 — admin+
  static bool canDeleteItem(SpaceSkinConfig skin, String? role) {
    if (!_isShop(skin)) return true;
    final r = parseRole(role);
    return r == ShopFamilyRole.owner || r == ShopFamilyRole.admin;
  }

  /// 管理成员/改角色 — owner
  static bool canChangeMemberRole(SpaceSkinConfig skin, String? role) {
    if (!_isShop(skin)) return parseRole(role) == ShopFamilyRole.owner;
    return parseRole(role) == ShopFamilyRole.owner;
  }

  /// 店铺设置、刷新邀请码等 — admin+
  static bool canManageShop(SpaceSkinConfig skin, String? role) {
    if (!_isShop(skin)) return true;
    final r = parseRole(role);
    return r == ShopFamilyRole.owner || r == ShopFamilyRole.admin;
  }

  /// 个人中心敏感设置（盘点/主题等）— clerk 不可见
  static bool canAccessProfileSettings(SpaceSkinConfig skin, String? role) {
    if (!_isShop(skin)) return true;
    return !isClerk(skin, role);
  }

  static String roleLabel(String? role, {required bool isShop}) {
    switch (parseRole(role)) {
      case ShopFamilyRole.owner:
        return isShop ? '老板' : '户主';
      case ShopFamilyRole.admin:
        return '管理员';
      case ShopFamilyRole.clerk:
        return '店员';
      case ShopFamilyRole.member:
        return isShop ? '成员' : '成员';
      case ShopFamilyRole.unknown:
        return '成员';
    }
  }

  static void logDenied(String action, String? role) {
    debugPrint('[ShopRoleGuard] WARN: 权限不足 action=$action role=$role');
  }
}
