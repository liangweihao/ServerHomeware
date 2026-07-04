# HomeStock 优化执行计划（2026-07-02）

> 依据：三方参考分析 + roadmap Epic E2/E4 + 组件工具风收尾  
> 状态：**已执行**（Phase A/B/C）

---

## 目标

在已有 Phase 1–3 交互优化基础上，补齐 **实时同步**、**UI 组件统一**、**搜索/录入闭环** 三块短板。

---

## Phase A — WebSocket 实时同步（Epic E2）

| # | 任务 | 说明 |
|---|------|------|
| A1 | 后端 `broadcast_family_event` | 物品 CRUD / 记消耗 / usage 创建后广播 |
| A2 | 客户端 `RealtimeSyncService` | 连接 `/ws/notifications`，心跳 pong |
| A3 | `RealtimeSyncBinder` | 登录后连接、登出断开，防抖拉取 sync |
| A4 | 事件处理 | `items_changed` / `usage_changed` / `alerts_changed` → ItemSync + EventBus |

**验收**：双设备记消耗，另一设备 ≤5s 内首页/提醒数据刷新。

---

## Phase B — UI 组件工具风收尾

| # | 任务 | 说明 |
|---|------|------|
| B1 | `AppFloatingActionButton` | 工具风黄 FAB / 卡通 FAB 双分支 |
| B2 | `AppTabBar` | 工具风 segmented / 卡通 segmented |
| B3 | `AppListEntrance` | 工具风轻 fade / 卡通弹性入场 |
| B4 | 页面迁移 | 购物清单、位置、分类、家庭、通知、使用记录 |

**验收**：默认 `utilityClean` 主题下无 cartoon_fab/tab_bar/list_entrance 直接引用。

---

## Phase C — 搜索/录入闭环（点评空结果行动）

| # | 任务 | 说明 |
|---|------|------|
| C1 | 搜索空结果 | 「手动添加」携带 query → `/items/add?name=` |
| C2 | AddItemPage | 支持 `initialName` 预填名称 |

**验收**：搜「创可贴」无结果 → 手动添加 → 向导 Step2 名称已填。

---

## 后续（本次不纳入）

- Epic E4 录入方式选择独立页 + OCR
- Epic E3 盘点任务
- 自动化测试框架
- CartoonScaffold 死代码删除

---

## 提测要点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 登录后 | WebSocket 连接成功，日志无 ERROR |
| T2 | 设备 A 记消耗 | 设备 B 自动刷新物品/提醒 |
| T3 | 购物清单 Tab | 工具风 segmented，黄 FAB |
| T4 | 搜索无结果 | 手动添加预填搜索词 |
| T5 | 切换卡通主题 | FAB/Tab 仍正常（卡通分支） |
