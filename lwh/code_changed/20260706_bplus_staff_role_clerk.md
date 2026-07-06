# B+ 店员角色 Epic 实现

> 日期：2026-07-06  
> PRD：[phase-b-staff-role-prd.md](../../doc/product/phase-b-staff-role-prd.md)

---

## 技术开发文档

### E1 服务端

- `app/core/shop_permissions.py` — shop 空间角色矩阵（home 跳过）
- `ItemService`：create/update/delete/use/bulk 权限校验
- `FamilyService`：加入 shop 默认 `clerk`；改角色仅 owner；移除成员支持 clerk 规则
- `GET /families/current` 返回 `current_user_role`

### E2 客户端 ShopRoleGuard

- `lib/core/auth/shop_role_guard.dart`
- `familyRoleProvider` + 登录/切家庭时同步 role
- UI：隐藏 CSV 入口、改价字段、删除物品、个人中心设置（店员）

### E3 成员角色管理

- `ShopFamilyMembersPage` — `/profile/family/roles`
- 老板可调整 admin/clerk/member
- `FamilyService.updateMemberRole`

---

## 提测开发文档

| # | 场景 | 预期 |
|---|------|------|
| 1 | shop 邀请码加入 | 新成员 role=clerk |
| 2 | 店员卖出/进货 | 成功 |
| 3 | 店员改售价 PUT | 403 |
| 4 | 店员 POST bulk | 403 |
| 5 | 店员 UI | 无 CSV、无改价字段、无删除 |
| 6 | 老板改角色 | 下拉生效 |
| 7 | home member | 行为不变 |

### 验证

```bash
cd HomeWareServer
$env:PYTHONPATH="." ; pytest tests/test_shop_permissions.py

cd HomeWareClient
flutter test test/core/auth/shop_role_guard_test.dart
```

---

## 影响文件

- `HomeWareServer/app/core/shop_permissions.py`
- `HomeWareServer/app/services/item_service.py`
- `HomeWareServer/app/services/family_service.py`
- `HomeWareClient/lib/core/auth/shop_role_guard.dart`
- `HomeWareClient/lib/presentation/profile/shop_family_members_page.dart`
