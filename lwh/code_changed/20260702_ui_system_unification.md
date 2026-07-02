# UI 统一规范落地（Phase UI-Unify）

**日期**：2026-07-02  
**规范文档**：[`doc/design/ui_system.md`](../../doc/design/ui_system.md)

---

## 一、技术开发文档

### 目标

解决「外壳工具风、内容卡通贴纸」割裂问题；默认 `utilityClean` 只维护一套组件语法。

### 新增组件

| 文件 | 职责 |
|------|------|
| `app_card.dart` | `AppCard` / `AppSectionCard` — 白卡 vs AppSurface |
| `app_list_row.dart` | `AppListRow` / `AppListDivider` — 设置列表行 |
| `app_section_header.dart` | 区块标题（工具风无 emoji 前缀） |
| `app_segment_chip.dart` | 统计页时间筛选 |
| `app_reason_tag.dart` | 物品出现理由 — TagChip / CartoonStickerBadge |

### 页面迁移（P0/P1）

| 页面 | 改动 |
|------|------|
| `profile_page.dart` | WarmScaffold + AppCard + AppListRow + Material Icons |
| `profile_panel_page.dart` | 功能列表 AppCard + AppListRow |
| `statistics_page.dart` | AppSegmentChip + AppSectionCard + AppSectionHeader |
| `edit_profile_page.dart` | `_wrapProfileCard` 工具风 AppCard |
| `category_management_page.dart` | 分类卡 AppCard |
| `item_card.dart` | 工具风 reasonFirst 用 AppReasonTag |

### 文档

- 新建 `doc/design/ui_system.md`（完整规范）
- 更新 `doc/design/design-system.md`、`doc/README.md` 索引

---

## 二、提测开发文档

### 测试点

1. **个人中心 Tab**：白卡列表、Material 图标、无 AppSurface 贴纸
2. **Profile Panel**：功能列表图标统一、数据导出/盘点可点
3. **数据统计**：本周/月/年 Chip 样式、各 Section 白卡
4. **编辑资料 / 分类管理**：表单区白卡、无倾斜阴影
5. **物品列表 reasonFirst**：理由标签为 TagChip 风格（非贴纸描边）
6. **切换卡通主题**：AppCard 等组件仍回退卡通分支

### 验证

热重启 → 默认主题目视上述页面；设置中切「卡通轻插画」确认回退正常。

### 待续（P2）— 已完成

详见 [`20260702_ui_system_unification_p2.md`](20260702_ui_system_unification_p2.md)

---

## 三、影响范围

- 客户端 UI 层：个人中心、统计、分类、物品卡片
- 无 API / 后端变更
