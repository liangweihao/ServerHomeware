# 个人中心 UI 重构（Profile Redesign）

**日期**：2026-07-02  
**规范**：[`doc/design/ui_system.md`](../../doc/design/ui_system.md)

---

## 一、技术开发文档

### 问题

原个人中心（Tab + Panel）为长列表堆叠，Panel 页混用 emoji、旧 Card 与 AppListRow，视觉层级弱、与首页 Bento 风格不一致。

### 方案

采用 **身份头图 + 三列概览 + 宫格快捷入口 + 分组设置** 布局，与首页 `TodaySummaryBanner`、统计页 Bento 卡片同一设计语言。

### 新增组件（`profile/widgets/`）

| 文件 | 职责 |
|------|------|
| `profile_identity_header.dart` | 渐变装饰头图、头像环、家庭/角色 TagChip |
| `profile_overview_strip.dart` | 三列数据概览（待处理/购物/支出等） |
| `profile_quick_action_grid.dart` | 4 列宫格快捷入口，支持角标 |
| `profile_family_card.dart` | 家庭信息、邀请码、成员头像叠放 |
| `profile_contribution_card.dart` | 本月贡献双指标 + 进度条 |

### 页面改动

| 页面 | 改动 |
|------|------|
| `profile_page.dart` | 全面重写为 Bento 布局；下拉刷新 |
| `profile_panel_page.dart` | 精简为共享组件组合；移除 emoji；修复邀请码复制 |
| `family_contribution_section.dart` | 统一 AppCard / AppSectionHeader |

### 设计要点

- 头图：主色渐变 + 装饰圆（非卡通贴纸，符合 utilityClean）
- 概览条：左上图标底 + 大数字，可点击跳转
- 宫格： tinted 图标底，提醒角标
- 黄色仍仅用于首页 FAB，个人中心不用 accentHighlight 作主色

### 创意加强（2026-07-02 续）

| 能力 | 说明 |
|------|------|
| `ProfileInventoryHealth` | 由临期/过期/低库存推导健康分 35–100 |
| `ProfileHealthRing` / `ProfileHealthBanner` | 渐变圆环 + 有问题时展开提示横幅 |
| 时段问候 | 早上好/下午好等 + 点阵底纹 + 漂浮家居图标 |
| Bento 宫格 | 物品/提醒首行大卡 + 水印图标 + 入场动效 |
| 概览脉冲 | 有待处理项时顶条高亮 + 脉冲点动画 |
| 贡献奖牌 | 排名 1–3 显示金银铜 Material 图标 |

---

## 二、提测开发文档

### 测试点

1. **Tab「我的」**：头图、三概览、8 宫格、管理与偏好列表
2. **首页头像 → 个人中心 Panel**：家庭卡、贡献卡、协作区块、同步状态、退出
3. **概览点击**：待处理→提醒、购物→清单、支出→统计
4. **宫格**：物品/提醒/通知/统计等待跳转正确；提醒角标
5. **家庭卡**：复制邀请码到剪贴板、刷新、切换家庭、管理成员
6. **下拉刷新**：Tab 与 Panel 数据更新
7. **卡通主题**：AppCard 等组件回退分支仍正常

### 验证

```powershell
cd HomeWareClient
flutter analyze
.\scripts\run_dev.ps1
```

热重启后对比改版前后截图；重点看 Tab 与 Panel 是否风格统一。

---

## 三、影响范围

- 客户端：`presentation/profile/` 及 widgets
- 无 API / 后端变更
