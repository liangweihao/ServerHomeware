# 核心业务流程

> **状态**：现行真源（2026-07-04）。每个流程标注关键类与 API。  
> 系统架构见 [system-overview.md](system-overview.md)。

---

## 1. 认证与启动

```mermaid
flowchart TD
  start([App 启动]) --> splash[SplashPage]
  splash --> hasToken{本地有 Token?}
  hasToken -->|否| welcome[WelcomePage]
  hasToken -->|是| refresh[ApiService.tryRefreshToken]
  refresh -->|成功| me[GET /users/me]
  refresh -->|失败| login[LoginPage]
  me -->|有效| home[首页 /]
  me -->|无效| login
  welcome --> login
  login --> authLogin[POST /auth/login]
  authLogin --> saveToken[存 JWT + SharedPreferences]
  saveToken --> hasFamily{有家庭?}
  hasFamily -->|否| createJoin[创建/加入家庭]
  hasFamily -->|是| home
  createJoin --> home
  home --> wsConnect[RealtimeSyncBinder 连接 WS]
```

| 步骤 | 关键文件 |
|------|----------|
| Token 校验 | `core/services/api_service.dart` |
| 认证状态 | `core/providers/auth_provider.dart` |
| 401 自动登出 | `core/providers/auth_guard.dart` |
| 服务端 | `app/api/v1/auth.py` |

**占位**：验证码登录、忘记密码为 Mock（验证码 `123456`）。

---

## 2. 添加物品

```mermaid
flowchart TD
  entry{入口}
  entry -->|首页/顶栏 +| method["/items/add/method"]
  entry -->|扫码| scan["/items/scan"]
  method -->|手动| wizard["/items/add 向导"]
  method -->|扫码| scan
  scan -->|识别条码| wizard
  wizard --> step1[Step1 基础信息]
  step1 --> step2[Step2 位置/数量]
  step2 --> step3[Step3 时效/图片]
  step3 --> upload[UploadService 上传图片]
  upload --> apiCreate[POST /items]
  apiCreate --> localSave[Drift insert/update]
  localSave --> usageIn[UsageRecord type=0 入库记录]
  usageIn --> syncPush[POST /usage_records]
  syncPush --> wsBroadcast[WS items_changed + alerts_changed]
  wsBroadcast --> done([返回列表/详情])
```

| 步骤 | 关键文件 |
|------|----------|
| 向导页 | `presentation/items/add_item_page.dart` |
| 方式选择 | `presentation/items/add_item_method_page.dart` |
| 物品 API | `core/services/item_service.dart` |
| 服务端 | `app/api/v1/items.py` |

**录入路径目标**：扫码 → 确认 → 完成，≤ 15 秒（Phase A M5 持续优化）。

---

## 3. 消耗 / 使用记录

```mermaid
flowchart TD
  trigger{触发入口}
  trigger -->|物品详情「用了1」| qc[QuickConsumeSheet]
  trigger -->|提醒中心| alertAct[AlertCenter 快捷操作]
  trigger -->|深链 ?action=consume| detail[ItemDetailPage]
  qc --> apply[applyItemUsage / recordQuickUsage]
  alertAct --> apply
  detail --> apply
  apply --> localUpdate[Drift 更新 quantity/status]
  localUpdate --> recordSync[UsageRecordSyncService.recordAndSync]
  recordSync --> apiPost[POST /usage_records]
  apiPost --> serverUpdate[服务端更新 Item 数量]
  serverUpdate --> wsBroadcast[WS usage_changed + items_changed + alerts_changed]
  wsBroadcast --> predict[ConsumptionPredictionService 更新预测]
  predict --> invalidate[invalidate Alert/Home Providers]
  invalidate --> done([UI 刷新])
```

| 类型 | UsageRecord.type | 说明 |
|------|------------------|------|
| 入库 | 0 | 添加物品时自动创建 |
| 消耗 | 1 | 用户「用了 N」 |
| 丢弃 | 2 | 过期丢弃 |

**注意**：客户端走 `POST /usage_records`，未直接调用 `POST /items/{id}/use`。

---

## 4. 数据同步

### 4.1 下行同步（全量合并）

```mermaid
flowchart LR
  trigger{触发时机}
  trigger -->|列表/首页加载| sync[ItemSyncService.syncFromServer]
  trigger -->|WS 事件 800ms 防抖| sync
  sync --> getItems[GET /items 全量]
  getItems --> merge[与 Drift 合并]
  merge -->|新 id| insert[insert]
  merge -->|已存在| update[更新 quantity/图片/过期等]
  insert --> usageSync[UsageRecordSyncService.syncBidirectional]
  update --> usageSync
  usageSync --> invalidate[invalidate Providers]
```

### 4.2 WebSocket 实时同步

```mermaid
sequenceDiagram
  participant A as 设备 A
  participant S as 服务端
  participant B as 设备 B
  A->>S: 修改物品/记消耗
  S->>S: 更新 DB
  S-->>B: WS {event: items_changed}
  B->>B: RealtimeSyncController 防抖 800ms
  B->>S: GET /items 全量
  S-->>B: 物品列表
  B->>B: Drift 合并 + invalidate Providers
```

| 事件 | 触发动作 |
|------|----------|
| `items_changed` | ItemSync + invalidate |
| `usage_changed` | UsageSync + invalidate |
| `alerts_changed` | invalidate Alert Providers |
| `ping` | 客户端回 `pong` |

**关键文件**：
- 客户端：`core/services/realtime_sync_service.dart`、`core/providers/realtime_sync_provider.dart`
- 服务端：`app/api/v1/ws.py`、`app/services/realtime_broadcast.py`

**未接**：`GET /sync/changes?since=` 增量同步（服务端已实现）。

---

## 5. 提醒与通知

```mermaid
flowchart TD
  subgraph calc [提醒计算]
    drift[Drift getAlertsForDisplay]
    celery[Celery 定时扫描]
    apiSummary[GET /alerts/expiring|low-stock]
  end

  subgraph display [展示]
    alertCenter["/alerts 提醒中心"]
    homeBanner[首页今日待办 Banner]
    homeSection[首页分区 Feed]
    badge[未读 Badge]
  end

  drift --> alertCenter
  drift --> badge
  apiSummary --> homeBanner
  apiSummary --> homeSection
  celery --> apiSummary

  alertCenter --> action{用户操作}
  action -->|记消耗| flow3[→ 消耗流程]
  action -->|丢弃| discard[recordItemDiscard]
  action -->|加清单| shopping[ShoppingService]
  action -->|已读| markRead[本地 markAllAlertsRead]
```

| 数据源 | 场景 |
|--------|------|
| **Drift 本地** | 提醒中心列表、未读 Badge |
| **服务端 API** | 首页四分区预览、统计摘要 |
| **WS 事件** | 触发重新 sync + invalidate |

提醒 Tab 分类：`all` / `expiry` / `stock` / `restock` / `warranty`。

---

## 6. 问管家（Assistant Phase 1）

```mermaid
flowchart TD
  entry[首页顶栏 问管家] --> chat["/assistant AssistantChatPage"]
  chat --> input[用户输入]
  input --> parser[AssistantParser 关键词/正则]
  parser --> intent{识别意图}
  intent -->|querySpaceItems| exec1[查空间物品]
  intent -->|queryItemLocation| exec2[查物品位置]
  intent -->|queryExpiring| exec3[查临期]
  intent -->|queryLowStock| exec4[查低库存]
  intent -->|queryPending| exec5[查待处理]
  intent -->|unknown| help[引导文案 + 建议 Chip]
  exec1 --> drift[(Drift 本地查询)]
  exec2 --> drift
  exec3 --> drift
  exec4 --> drift
  exec5 --> drift
  drift --> bubble[AssistantMessageBubble + 结果列表]
  bubble --> tap[点击跳转 /items/:id]
```

| 特性 | 说明 |
|------|------|
| 离线可用 | 纯本地 Drift，无 LLM |
| 不支持写操作 | 引导用户使用「+」或物品详情 |
| 测试 | `test/core/assistant/assistant_parser_test.dart` |

**关键文件**：`core/assistant/assistant_parser.dart`、`assistant_executor.dart`

---

## 7. 家庭协作

```mermaid
flowchart TD
  user[用户] --> family[Family 租户]
  family --> members[FamilyMember 角色]
  members --> owner[owner 创建者]
  members --> admin[admin 管理员]
  members --> member[member 普通成员]
  family --> items[共享物品/位置/分类]
  family --> ws[WS 按 family_id 广播]
  family --> contrib[贡献度统计 /profile/family/contribution]
```

角色权限链：`require_member` → `require_admin` → `require_owner`（服务端 `core/dependencies.py`）。

切换家庭：`FamilyService.switchFamily` → 刷新 Token 家庭上下文 → 重连 WS → 全量 sync。

---

## 8. 实现状态速查

| 流程 | 状态 | 备注 |
|------|------|------|
| 密码认证 | ✅ | |
| 添加物品 | ✅ | 含向导 + 扫码 |
| 消耗记录 | ✅ | M2 一键消耗 |
| 全量同步 | ✅ | |
| WS 实时 | ✅ | 需 websockets 包 |
| 提醒闭环 | ✅ | 提醒 → 消耗/丢弃/加清单 |
| 问管家查询 | ✅ | M1 部分 |
| 增量 sync | ⚠️ | API 有，客户端未接 |
| 问管家写操作 | ❌ | 规划中 |
| SMS 验证码 | ⚠️ Mock | |
