# UI 统一规范落地（Phase UI-Unify P2）

**日期**：2026-07-02  
**前置文档**：[`20260702_ui_system_unification.md`](20260702_ui_system_unification.md)、[`doc/design/ui_system.md`](../../doc/design/ui_system.md)

---

## 一、技术开发文档

### 目标

完成 `ui_system.md` §八 P2 迁移清单，将设置页、家庭协作、物品向导/详情、提醒卡片等零星页面统一到 `AppCard` / `AppListRow` / `AppSectionHeader` / `AppReasonTag` 体系。

### 改动文件

| 文件 | 改动 |
|------|------|
| `theme_settings_page.dart` | 新建主题选择页（AppCard + 三主题单选） |
| `app_router.dart` | 注册 `/profile/theme-settings` |
| `notification_settings_page.dart` | AppCard + AppListRow + SwitchListTile |
| `auth_cartoon_wrap.dart` | 工具风分支改用 AppCard |
| `add_item_page.dart` | 向导内容外包 AppCard |
| `edit_item_page.dart` | 与添加入库一致，向导外包 AppCard |
| `item_detail_page.dart` | `_buildSectionLabel` → `AppSectionHeader` |
| `alert_card.dart` | `TagChip` → `AppReasonTag.plain` |
| `profile_panel_page.dart` | 邀请码按钮「📋 复制」→「复制」 |
| `family_contribution_page.dart` | 区块标题 AppSectionHeader，空态/排行/动态 AppCard |
| `family_management_page.dart` | 工具风成员行 AppCard + AppListRow |
| `warm_search_result_tile.dart` | **删除**（已无引用） |

### 保留卡通分支（符合规范）

- `item_card.dart` 卡通路径
- `space_card` / `location_card` / `shopping_item_card` / `stat_card` 的 `_buildCartoonCard`
- `family_management` / `notification_center` 的 `CartoonListTile` 回退

---

## 二、提测开发文档

### 测试点

1. **主题设置**：个人中心 → 主题样式 → 三选项可切换，默认「清爽工具」
2. **通知设置**：开关列表白卡样式、Switch 正常
3. **添加入库 / 编辑物品**：向导表单在白卡内，底部导航不受影响
4. **物品详情**：「状态总览 / 详细信息 / 使用记录」标题样式与统计页一致
5. **提醒中心**：卡片标签为 TagChip 风格（工具风），点击行为不变
6. **家庭协作 / 成员管理**：排行与动态白卡；成员行可编辑/删除
7. **Profile Panel**：邀请码「复制」按钮无 emoji

### 验证方式

```powershell
cd HomeWareClient
flutter analyze
.\scripts\run_dev.ps1
```

热重启后目视上述页面；切换卡通主题确认回退分支仍正常。

### 注意事项

- 黄色 FAB / 首页「+」规则未改
- 无后端 / API 变更

### 编译修复（2026-07-02 续）

- `AppReasonTag` 主构造去掉 `const`（`ItemListReason` 非编译期常量）
- `AppListDivider` 去掉 `const Padding`（`AppColors.homeDivider` 为运行时 getter）

---

## 三、影响范围

- 客户端 UI：设置、家庭、物品向导/详情、提醒卡片
- 删除死代码 1 文件，无破坏性 API 变更
