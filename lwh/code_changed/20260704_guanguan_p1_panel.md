# 管管 P1 今日面板

**日期**：2026-07-04  
**状态**：已完成（P1-A/B/C MVP）  
**PRD**：[`doc/product/guanguan-butler-panel-prd.md`](../../doc/product/guanguan-butler-panel-prd.md)

---

## 一、技术开发说明

### 交付范围

| 批次 | 能力 | 状态 |
|------|------|------|
| P1-A | 首页可折叠「管管今日面板」+ 今日任务 Top3 | ✅ |
| P1-B | 无待办时每日结算 Banner（每天一次） | ✅ |
| P1-C | 厨房 7 日熟练度 Lv + 协作态一句话 + 闲置洞察 | ✅ |

### 首页信息架构

```
每日一危机 Banner（有待办时）
每日结算 Banner（无待办，每天首次）
管管今日面板（可折叠，持久化）
分区 Feed
按空间
```

### 数据逻辑

| 字段 | 实现 |
|------|------|
| 今日任务 | `computeItemListReason.isActionable` + `sortItemsByUrgency` Top3 |
| 厨房熟练度 | 7 日内厨房树物品录入/消耗次数；每 5 次 +1 级 |
| 协作态 | `familyContributionLeaderboardProvider` → 规则文案 |
| 闲置洞察 | 30 天无 touch 的在用物品 |

### 新增文件

| 路径 | 职责 |
|------|------|
| `core/assistant/guanguan_panel_models.dart` | 面板模型 |
| `core/assistant/guanguan_panel_builder.dart` | 纯函数构建 |
| `core/services/guanguan_panel_prefs.dart` | 折叠态 / 结算日 |
| `presentation/home/providers/guanguan_panel_provider.dart` | Riverpod |
| `presentation/home/widgets/guanguan_panel_card.dart` | 面板 UI |
| `presentation/home/widgets/guanguan_daily_settlement_banner.dart` | 结算条 |
| `test/core/assistant/guanguan_panel_builder_test.dart` | 单测 |

### 改动文件

- `presentation/home/home_page.dart` — 接入面板 + 结算 + 刷新 invalidate

---

## 二、提测说明

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 首页有待办 | 危机 Banner + 面板任务列表 ≤3 |
| T2 | 点击任务 | 跳转物品详情 |
| T3 | 点击面板标题 | 折叠/展开，重启 App 保持 |
| T4 | 无待办首次进首页 | 绿色结算条 + 面板「今天没有待办」 |
| T5 | 熟练度 | 显示厨房 Lv 与 7 日次数进度条 |
| T6 | 多人协作有记录 | 协作态一句话 |
| T7 | 下拉刷新 | 面板数据更新 |
| T8 | 单测 3 用例 | 全绿 |

### 验证命令

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/assistant/guanguan_panel_builder_test.dart
```

---

## 三、后续（P2）

- 周报 Insight 卡（`backpack_open`）
- 连续 7 天绿 → 零浪费成就
- 任务完成数实时进度（需统一 hook 庆祝回调）
