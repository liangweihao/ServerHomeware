# 切换家庭弹窗：编辑/删除与角色权限

## 实现方案

### 服务端
- 新增 `PUT /api/v1/families/{family_id}`，支持 owner/admin 修改家庭名称
- `FamilyService.update_family`：校验成员角色、名称长度 1–50

### 客户端
- `FamilyService.updateFamily` 对接上述接口
- `SwitchFamilyBottomSheet` 重构「更多」菜单：
  - 使用 `showMenu` 锚定在 ··· 按钮
  - **owner / admin**：显示 ···；可编辑家庭名称
  - **owner**：可删除（含当前家庭、唯一家庭；删除后自动切换或置空并关闭弹窗）
  - **member**：不显示 ···
- 家庭卡片使用列表 API 返回的 `role`、`member_count`、`item_count`

### 文档
- 更新 `doc/appPhase/Phase 9：切换家庭弹窗.md`
- 更新 `doc/serverPhase/Phase 3：家庭协作 & 数据同步.md`（PUT 家庭）
- 更新 `doc/原型图.md`（切换家庭弹窗与权限表）

## 影响范围

| 文件 | 变更 |
|------|------|
| `HomeWareServer/app/api/v1/families.py` | 新增 PUT 路由 |
| `HomeWareServer/app/services/family_service.py` | 新增 update_family |
| `HomeWareClient/lib/core/services/family_service.dart` | 新增 updateFamily |
| `HomeWareClient/.../switch_family_bottom_sheet.dart` | 编辑/删除/权限 UI |

## 提测要点

1. **owner** 删除非当前家庭：··· → 删除 → 确认
2. **owner** 删除**当前家庭**：可删，Dialog 有橙色提示，成功后弹窗关闭、个人页刷新
3. **admin**：仅编辑，无删除项
4. **member**：无 ··· 按钮
5. 仅剩 1 个家庭：删除可用，Dialog 与菜单有橙色/灰色说明
6. 编辑空名称：客户端拦截；超长名称：服务端 400
7. 删除需输入完整家庭名称才能确认
