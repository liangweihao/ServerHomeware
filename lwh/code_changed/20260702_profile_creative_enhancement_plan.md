# 个人中心创意增强 — 分步执行计划

**日期**：2026-07-02  
**前置**：[`20260702_profile_ui_redesign.md`](20260702_profile_ui_redesign.md)

---

## 总览

| 阶段 | 功能 | 状态 |
|------|------|------|
| **A** | 头图随健康分变色 | ✅ 已完成 |
| **B** | 宫格长按快捷操作 | ✅ 已完成 |
| **C** | 贡献排行 Top3 领奖台 | ✅ 已完成 |
| **D** | 领奖台点击成员详情 | ✅ 已完成 |
| **E** | 健康分变化过渡动画 | ✅ 已完成 |
| **F** | 成员贡献详情独立路由 | ✅ 已完成 |
| **G** | 健康分 7 日历史曲线 | ✅ 已完成 |
| **H** | 领奖台分享海报 | ✅ 已完成 |
| **I** | 分享海报美化模板 | ✅ 已完成 |
| **J** | 成员分类统计 | ✅ 已完成 |

---

## Phase A — 头图随健康分变色

### 目标

个人中心身份头图背景渐变、点阵、装饰圆、问候文字色随 `ProfileInventoryHealth` 动态变化。

### 实现

1. `ProfileInventoryHealth` 增加 `headerGradient`、`dotColor`、`greetingColor`
2. `ProfileIdentityHeader` 使用 health 主题色替代固定 primary
3. 健康 / 警告 / 危险三档视觉区分

### 测试点

- 无待办 → 绿色系渐变
- 仅临期/低库存 → 橙色系
- 有过期 → 红色系

---

## Phase B — 宫格长按快捷操作

### 目标

常用功能宫格 **长按** 弹出快捷菜单，减少跳转层级（类似 iOS 3D Touch / 微信小程序长按）。

### 实现

1. `ProfileQuickAction` 增加 `shortcuts: List<ProfileQuickShortcut>?`
2. `ProfileQuickActionGrid` 长按弹出 `ModalBottomSheet`
3. `profile_page.dart` / `profile_panel_page.dart` 为物品、提醒、购物等配置快捷项

### 快捷项设计

| 入口 | 长按快捷 |
|------|----------|
| 物品 | 添加入库、扫码录入 |
| 提醒 | 临期、低库存、全部 |
| 购物 | 打开清单 |
| 统计 | 本周、本月 |
| 协作 | 贡献详情 |

### 测试点

- 短按仍走原路由
- 长按弹出 Sheet，点选项正确跳转
- 无 shortcuts 的项长按无反应

---

## Phase C — 贡献排行 Top3 领奖台

### 目标

家庭协作区块 Top3 使用 **领奖台布局**（2-1-3 经典站位），4 名及以后保持列表。

### 实现

1. 新建 `profile_contribution_podium.dart`
2. `FamilyContributionSection` ≥3 人时展示领奖台 + 余下列表
3. `FamilyContributionPage` 详情页同步使用

### 测试点

- 0 人：空态
- 1–2 人：简化柱形（无空位）
- ≥3 人：领奖台 + 列表
- 点击成员无跳转（仅展示，与现有一致）

---

## 影响范围

- `profile/widgets/*`
- `profile_page.dart`、`profile_panel_page.dart`
- `family_contribution_section.dart`、`family_contribution_page.dart`
- 无后端变更

---

## 执行记录

| 阶段 | 改动文件 |
|------|----------|
| A | `profile_inventory_health.dart`、`profile_identity_header.dart` |
| B | `profile_quick_action_grid.dart`、`profile_quick_actions_config.dart`、`profile_page.dart`、`profile_panel_page.dart` |
| C | `profile_contribution_podium.dart`、`family_contribution_section.dart`、`family_contribution_page.dart` |
