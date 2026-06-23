# PRD: 首页通知中心（Home Notification Center）

**Author:** Product / AI-assisted | **Status:** Shipped | **Date:** 2026-06-22  
**Epic:** E1（[roadmap.md](../roadmap.md)） | **IA 参考：** [information-architecture.md](../../design/information-architecture.md)

---

## 1. Summary

将首页 AppBar 的 🔔 占位入口（当前仅弹出 SnackBar「暂无新通知」）升级为**真实通知中心**，聚合家庭物品提醒摘要，并与底部「提醒」Tab 共用同一数据源与未读计数。用户可在首页快速浏览「今天要处理什么」，点击条目跳转物品详情或提醒 Tab，无需先切换 Tab。本 PRD 覆盖 **客户端本地提醒**（Drift）；服务端 Push / WebSocket 实时同步属 Epic E2，不在本期范围。

---

## 2. Contacts

| 角色 | 姓名 | 职责 |
|------|------|------|
| PM | TBD | 范围决策、验收 |
| 客户端负责人 | TBD | Flutter 页面、Provider、Drift |
| 服务端负责人 | TBD | 本期仅消费既有 `/alerts/summary`（可选联调） |
| 设计 | TBD | 通知中心 UI、Badge 规范 |

---

## 3. Background

### 触发原因

- 首页 `home_page.dart` 中 🔔 为**硬编码红点 + 占位 SnackBar**，与产品「省心提醒」定位不符。
- 底部 Tab Badge 使用 `alertCountProvider`（`database_provider.dart` → `getAlertCount()`），仅统计**过期 + 库存**；`notification_provider.dart` 另有重复 Provider 统计 4 类提醒，存在**计数不一致**风险。
- 提醒 Tab（`/alerts`）功能完整，但用户习惯在首页 AppBar 找「通知」；双入口职责未定义，体验割裂。

### 既有能力（可复用）

| 层级 | 能力 | 位置 |
|------|------|------|
| 客户端 | 4 类提醒查询 | `AppDatabase.getExpiryAlerts()` 等 |
| 客户端 | 提醒卡片 UI | `AlertCard` |
| 客户端 | Tab Badge | `MainScaffold` + `alertCountProvider` |
| 服务端 | 提醒列表 / 摘要 API | `GET /api/v1/alerts`、`GET /api/v1/alerts/summary` |
| 服务端 | 标记已读（预留） | `POST /api/v1/alerts/{id}/read`（当前无持久化） |

### 约束与假设

- **Assumption 1**：MVP 阶段提醒数据以**本地 Drift** 为主（与现 `/alerts` 一致）。
- **Assumption 2**：已读/忽略状态本期存**本地**（Drift 新表或扩展现有表），不要求服务端已读同步（E2 再议）。
- **Constraint**：不引入 FCM/APNs、微信/短信等站外通道。
- **Constraint**：不重构提醒 Tab，仅统一数据源与 Badge 规则。

---

## 4. Objective

### 目标

1. **Primary**：首页 🔔 打开真实通知中心，展示未处理提醒列表（按紧急度排序），P95 打开耗时 ≤ 300ms（本地数据）。
2. **Secondary**：AppBar Badge、通知中心未读数、提醒 Tab Badge **三处数字一致**。
3. **Secondary**：通知入口点击率较现状提升 ≥ 30%（内测埋点，基线≈0 有效交互）。

### Non-Goals（明确不做）

- 操作系统级 Push 通知（FCM/APNs）
- WebSocket 实时推送（→ Epic E2）
- 营销类 / 系统公告类通知
- 服务端 `mark_alert_read` 持久化（可预留接口调用，非验收项）
- 重写提醒 Tab 的 Tab 筛选与卡片操作逻辑

---

## 5. Market Segments

| Segment | 规模（假设） | 优先级 | 说明 |
|---------|--------------|--------|------|
| 家庭主理人（采购/管库存） | 核心用户 ~70% | P0 | 每日查看过期/补购，首页入口最高频 |
| 家庭成员（协作查看） | ~25% | P1 | 需看到家庭共有提醒，切换家庭后列表刷新 |
| 单人试用用户 | ~5% | P2 | 提醒少，空状态引导录入/设置 |

---

## 6. Value Propositions

| 用户类型 | Job-to-be-Done | 痛点 | 收益 |
|----------|----------------|------|------|
| 家庭主理人 | 早上打开 App 知道今天该处理什么 | 点击 🔔 无内容，不信任产品 | 一屏汇总过期/库存/补购/保修 |
| 家庭主理人 | 从通知直达物品处理 | 需先切 Tab 再查找 | 点击通知 → 物品详情或提醒 Tab 对应分类 |
| 全体成员 | 看到一致的待办数量 | Badge 与真实提醒不符 | 数字统一，减少困惑 |

---

## 7. Solution

### 7.1 信息架构

**新增路由**：`/notifications`（全屏二级页，无底部 Tab，`SlideTransitionPage`）

**入口**：

- 首页 AppBar 🔔（主入口）
- （P1）提醒 Tab 顶部「最近」区块可链入同一页 — 可选

**页面结构（文字线框）**：

```
┌─────────────────────────────────────────┐
│ ←  通知中心              [全部已读]      │
│─────────────────────────────────────────│
│  今天 · 3 条未处理                       │
│  ┌─────────────────────────────────┐    │
│  │🔴 牛奶 · 明天过期          ›    │    │
│  │   厨房 › 冰箱                   │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │📦 洗衣液 · 库存不足        ›    │    │
│  └─────────────────────────────────┘    │
│  …（按 urgency 排序，默认最多展示 20 条）│
│─────────────────────────────────────────│
│  [查看全部提醒 → /alerts]              │
└─────────────────────────────────────────┘
```

**空状态**：

```
┌─────────────────────────────────────────┐
│ ←  通知中心                              │
│         🎉                               │
│    暂无需要处理的事项                     │
│    去添加物品或查看提醒设置               │
│  [添加物品]  [提醒设置]                   │
└─────────────────────────────────────────┘
```

### 7.2 数据模型

#### 通知条目（视图模型，不一定落库）

| 字段 | 来源 | 说明 |
|------|------|------|
| id | `item.id` + `alertType` | 复合键，如 `123_expiry` |
| itemId | Item | 跳转详情 |
| type | expiry/stock/restock/warranty | 与 `AlertCard` 一致 |
| title / message | 计算 | 复用 `AlertCard._getAlertInfo()` 文案 |
| urgency | 1–3 | 过期越近越高；已过期 = 3 |
| isRead | 本地 | 见下表 |
| createdAt | `item.updatedAt` 或 `expiryDate` | 排序辅助 |

#### 本地已读/忽略（新增 Drift 表 `AlertReadStates`）

| 列 | 类型 | 说明 |
|----|------|------|
| id | int PK | |
| itemId | int | 物品 ID |
| alertType | text | expiry / stock / restock / warranty |
| familyId | int | 切换家庭隔离 |
| readAt | datetime | 标记已读时间 |
| ignored | bool | 用户「忽略」 |

> **迁移**：Alembic 非必须（纯客户端）；Drift schema version + migration。

**未读定义**：当前家庭下，满足提醒条件且 `(itemId, alertType)` **不在** `AlertReadStates`（或 `ignored=false` 且未 read）的条目。

**与提醒 Tab 对齐**：提醒 Tab 的「忽略」应写入同一表；「全部已读」写入 batch read（修复现有 `_markAllAsRead` 仅清空内存 Set 的问题）。

### 7.3 Badge 统一规则

| 位置 | 规则 |
|------|------|
| 首页 AppBar 🔔 | 未读总数；0 时不显示 Badge/红点 |
| 底部提醒 Tab | 与 AppBar **相同** `unreadAlertCountProvider` |
| 通知中心标题区 | 文案「今天 · N 条未处理」 |

**统计范围**：过期 + 库存 + 补购 + 保修（与 `AlertCenterPage` 四类一致，**修复** `getAlertCount()` 仅算两类的问题）。

### 7.4 User Stories

#### P0 — Must Have

**US-1：打开通知中心**

> As a **家庭主理人**,  
> I want **to tap the bell icon on the home screen and see my pending alerts**,  
> so that **I can quickly know what needs attention today**.

**Acceptance Criteria:**

- [ ] Given 存在未读提醒，When 点击首页 🔔，Then 导航至 `/notifications` 并展示列表（非 SnackBar）
- [ ] Given 无未读提醒，When 打开通知中心，Then 展示空状态 + 引导按钮
- [ ] Given 列表加载，When 使用本地 Drift 数据，Then P95 首屏渲染 ≤ 300ms（100 条物品规模）

```gherkin
Scenario: 打开通知中心看到未读列表
  Given 家庭内有 2 条过期提醒且未读
  When 用户在首页点击通知图标
  Then 进入通知中心页面
  And 列表显示 2 条提醒
  And 标题区显示「2 条未处理」
```

---

**US-2：从通知跳转处理**

> As a **家庭主理人**,  
> I want **to tap a notification row to open the related item**,  
> so that **I can act on it immediately**.

**Acceptance Criteria:**

- [ ] Given 通知列表某行，When 点击，Then 跳转 `/items/:id`
- [ ] Given 从详情返回，When 用户未处理该提醒，Then 通知中心仍显示该条（仍为未读）
- [ ] Given 用户在详情完成「使用/丢弃/加入清单」，When 返回，Then 若不再满足提醒条件则自动从未读列表消失

---

**US-3：全部已读**

> As a **用户**,  
> I want **to mark all notifications as read**,  
> so that **badges clear when I've reviewed them**.

**Acceptance Criteria:**

- [ ] Given 通知中心有 N 条未读，When 点击「全部已读」，Then AppBar 与 Tab Badge 变为 0
- [ ] Given 全部已读，When 物品仍满足提醒条件，Then 提醒 Tab 仍可在对应分类中看到（**已读 ≠ 已处理**）
- [ ] Given 全部已读，Then 状态持久化到 Drift，重启 App 后 Badge 仍为 0（直至产生新提醒或用户撤销）

---

**US-4：Badge 三处一致**

> As a **用户**,  
> I want **the same unread count on the home bell and alerts tab**,  
> so that **I trust the numbers**.

**Acceptance Criteria:**

- [ ] Given 4 类提醒各有未读，When 任意页面，Then AppBar Badge 数 = Tab Badge 数 = `unreadAlertCountProvider`
- [ ] Given 切换家庭，When 完成加载，Then Badge 更新为当前家庭未读数
- [ ] 移除首页 🔔 **硬编码红点**（`home_page.dart` 中固定 8×8 容器）

---

**US-5：查看全部提醒**

> As a **用户**,  
> I want **a link to the full alert center with filters**,  
> so that **I can manage alerts in depth**.

**Acceptance Criteria:**

- [ ] 通知中心底部固定 CTA「查看全部提醒」→ `context.go('/alerts')`
- [ ] 列表默认最多 20 条，按 urgency 降序；超出时仍可通过 CTA 进入完整 Tab 页

#### P1 — Should Have

**US-6：在线摘要校准（可选）**

> As a **用户**,  
> I want **notification counts to refresh from server when online**,  
> so that **multi-device edits are reflected sooner**（完整实时 → E2）.

**Acceptance Criteria:**

- [ ] Given 网络可用，When 打开通知中心，Then 后台调用 `GET /alerts/summary` 并 merge 本地（冲突以服务端物品状态为准）
- [ ] Given 离线，When 打开，Then 仅本地 Drift，无 blocking 错误

**US-7：按类型分组标题**

- [ ] 列表可按「即将过期 / 库存不足 / 建议补购 / 保修」分组展示（折叠可选）

#### P2 — Nice to Have

**US-8：下拉刷新**

- [ ] 通知中心支持下拉触发 `ItemSyncService` 增量同步

### 7.5 技术方案摘要

| 模块 | 改动 |
|------|------|
| `app_router.dart` | 新增 `/notifications` → `NotificationCenterPage` |
| `home_page.dart` | 🔔 `onPressed` → `context.push('/notifications')`；Badge 接 Provider |
| `core/providers/alert_provider.dart`（新） | `unreadAlertCountProvider`、`notificationListProvider`；合并删除重复 `notification_provider.alertCountProvider` |
| `app_database.dart` | 新表 `AlertReadStates`；`getUnreadAlertCount()`；统一 4 类提醒查询 |
| `alert_center_page.dart` | 忽略/全部已读改走 Drift；与通知中心共享 Repository |
| `main_scaffold.dart` | Badge 改用 `unreadAlertCountProvider` |
| 日志 | 打开通知中心、全部已读、跳转详情打 INFO；Drift 失败打 ERROR |

**不动**：`HomeWareServer` 业务逻辑（除可选 summary 联调）；Epic E2 WebSocket。

### 7.6 Dependencies

| 依赖 | 负责人 | 状态 | 说明 |
|------|--------|------|------|
| Drift migration | 客户端 | 待开发 | AlertReadStates 表 |
| AlertCard 文案逻辑 | 客户端 | ✅ 已有 | 抽取 shared helper |
| `/alerts/summary` API | 服务端 | ✅ 已有 | P1 可选 |
| 设计稿 | 设计 | 待产出 | 可先用 IA 线框开发 |

### 7.7 Risks & Mitigations

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| 已读 vs 已处理概念混淆 | 中 | 中 | 文案区分；提醒 Tab 仍保留操作按钮 |
| Badge 与提醒 Tab 列表不一致 | 中 | 高 | 单一 Provider + 单一 Drift 查询 |
| Drift 迁移丢数据 | 低 | 中 | 新表仅增不改；迁移测试 |
| 性能：全量扫描物品 | 低 | 中 | 复用现有索引；列表 cap 20 |

### 7.8 非功能需求（NFR）

| 类别 | 要求 |
|------|------|
| 性能 | 通知中心首屏 ≤ 300ms（本地 100 物品）；列表滚动 60fps |
| 离线 | 完全可用；无网络不阻塞 |
| 无障碍 | 列表项 `Semantics(label: 物品名+提醒类型+日期)`；Badge 有文字备选 |
| 触控 | 行高 ≥ 56dp；返回与「全部已读」≥ 44dp |
| 安全 | 仅当前家庭数据；切换家庭清空内存缓存 |
| 日志 | 关键流程 INFO；异常 ERROR（见 7.5） |

---

## 8. Release

### 里程碑

| 里程碑 | 目标日期 | 交付物 | 状态 |
|--------|----------|--------|------|
| M1 设计评审 | 2026-07-01 | 线框 + Badge 规范 | 待开始 |
| M2 开发完成 | 2026-07-15 | PRD 全部 P0 + Drift 迁移 | 待开始 |
| M3 内测 | 2026-07-22 | 5–10 家庭试用 | 待开始 |
| M4 全量 | 2026-08-01 | 合并 main | 待开始 |

### Success Metrics

| 指标 | 当前基线 | 目标 | 观测窗口 |
|------|----------|------|----------|
| 通知入口有效点击率 | ~0%（SnackBar） | ≥ 30% DAU 点击 🔔 | 内测 2 周 |
| 通知 → 详情转化率 | N/A | ≥ 50% 点击列表行 | 内测 2 周 |
| Badge 与列表条数一致率 | 未测 | 100% 自动化用例 | 发布前 |
| 提醒 Tab 跳转率（来自通知 CTA） | N/A | ≥ 15% 通知页 UV | 内测 2 周 |

### Go / No-Go（发布门禁）

| 检查项 | 阈值 |
|--------|------|
| P0 用户故事全部验收 | 100% |
| Badge 一致自动化测试 | 通过 |
| 无 P0/P1 崩溃 | 0 |
| 产品 Demo 通过 | PM 签字 |

**Go 建议分**：≥ 7.0（范围清晰、复用度高、无服务端阻塞）→ **建议 Go**

---

## 附录 A：与 Epic E2 边界

| 能力 | E1（本期） | E2（后续） |
|------|------------|------------|
| 通知列表数据 | 本地 Drift | + WebSocket 增量 |
| 已读状态 | 本地持久化 | 可选服务端同步 |
| Push | 无 | FCM/APNs 单独立项 |

---

## 附录 B：相关代码索引

- 占位入口：`HomeWareClient/lib/presentation/home/home_page.dart`（L60–65）
- Tab Badge：`HomeWareClient/lib/presentation/common/widgets/main_scaffold.dart`
- 提醒页：`HomeWareClient/lib/presentation/alerts/alert_center_page.dart`
- 计数：`HomeWareClient/lib/data/database/app_database.dart` → `getAlertCount()`
- 服务端：`HomeWareServer/app/api/v1/alerts.py`

---

## 附录 C：文档联动

- 实现后更新 [information-architecture.md](../../design/information-architecture.md) §九路由表
- 交付后写 `lwh/code_changed/YYYYMMDD_notification_center.md`
- Epic E2 PRD 待 E1 发布后起草
