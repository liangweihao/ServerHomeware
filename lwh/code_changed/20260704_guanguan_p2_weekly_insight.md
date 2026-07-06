# 管管 P2 — 周报 Insight 与零浪费成就

**日期**：2026-07-04  
**状态**：已交付  
**PRD**：[`doc/product/guanguan-butler-panel-prd.md`](../../doc/product/guanguan-butler-panel-prd.md) §4.3

---

## 一、实现方案

| 能力 | 路径 | 说明 |
|------|------|------|
| 周报构建 | `core/assistant/guanguan_weekly_insight_builder.dart` | 近 7 日录入/消耗/新入库 + 健康分连续绿 |
| 模型 | `core/assistant/guanguan_weekly_insight_models.dart` | `GuanguanWeeklyInsight`、`zeroWasteWeek` 成就 |
| 话术 | `core/assistant/guanguan_copy.dart` | 周报标题、成就文案 |
| 偏好 | `core/services/guanguan_weekly_insight_prefs.dart` | 按自然周（周一）收起 |
| Provider | `presentation/home/providers/guanguan_weekly_insight_provider.dart` | 无数据或已收起 → 不展示 |
| UI | `presentation/home/widgets/guanguan_weekly_insight_card.dart` | 首页面板下方 Insight 卡 |
| 动效 | `presentation/home/widgets/guanguan_backpack_reveal.dart` | 背包打开缩放（`backpack_open` 占位） |

### 零浪费成就

- 条件：健康分历史 **连续 7 天 score=100**（无过期/临期/低库存）
- 数据源：`ProfileHealthHistoryService`（首页 stats 每日写入）
- 展示：Insight 卡内绿色成就徽章

### 展示规则

- 位置：首页 `GuanguanPanelCard` 下方
- 有录入/消耗/新入库/成就/连续绿≥3 天之一即显示
- 用户点 ✕ → 本周不再显示（SharedPreferences）

---

## 二、提测

| # | 步骤 | 预期 |
|---|------|------|
| 1 | 近 7 日有消耗或录入 | 首页出现「本周复盘」卡 + 背包动效 |
| 2 | 点右上角关闭 | 本周不再出现 |
| 3 | 下拉刷新 | 卡片数据更新 |
| 4 | 模拟 7 天满分健康分 | 显示「本周零浪费」成就徽章 |
| 5 | 本周完全无动作 | 卡片隐藏 |

### 自动化

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/assistant/guanguan_weekly_insight_builder_test.dart
```

---

## 三、后续

- 设计师 `backpack_open` 序列帧替换 `GuanguanBackpackReveal` 图标
- Phase B：同一卡片换「后厨档口」文案皮肤
- 个人中心可复用成就徽章（可选）
