# 长时间未使用提醒 — 评审问题修复

**日期**：2026-07-20  
**模块**：server + client  
**关联**：`20260720_idle_reminder_ai.md`

---

## 修复目标

针对评审指出的三项优先问题：

1. 本地使用不写 `lastUsedAt`
2. 服务端 AI 文案未进入客户端 UI
3. 历史 `last_used_at` 未回填导致老库存误报

并顺带修复阻塞 Celery 任务加载的既有缺陷。

---

## 实现方案

### 产品策略（AI 文案路径）

```
本地 getIdleAlerts()     → 决定「哪些物品要提醒」（离线可用）
服务端 notifications(idle) → AI body 覆盖展示文案（有网时）
```

不改通知中心数据结构主体，通过 `descriptionOverride` 叠加服务端文案。

### 服务端

| 改动 | 说明 |
|------|------|
| `0013_backfill_last_used_at.py` | 用 `usage_records(type=1)` 的 `MAX(created_at)` 回填 |
| `generate_idle_reminders` | 任务开始时幂等再回填一次；删除无效 select；UTC 今日起点；naive/aware 统一 |
| `_default_idle_result` | AI 失败按分类阈值降级（清洁 60 天等），不再全量提醒 |
| `get_sync_session` | `sqlite+aiosqlite` / `postgresql+asyncpg` 转为同步 URL |
| `Shopping` → `ShoppingItem` | 修复模块无法 import、Celery 任务无法注册的问题 |

### 客户端

| 改动 | 说明 |
|------|------|
| `insertUsageRecord` | `type==1` 时同步写 `items.lastUsedAt` |
| `IdleReminderService` | 拉取 `/notifications?type=idle` |
| `idleMessageByLocalItemIdProvider` | server item_id → 本地 itemId 映射 |
| `NotificationEntry.descriptionOverride` | 通知中心展示 AI 文案 |
| `AlertCard.descriptionOverride` | 提醒中心同步覆盖 |
| `findIdleItems` | 时间源：UsageRecord → lastUsedAt → createdAt |
| idle「已知晓」 | 提醒中心为 idle 接通 `onAcknowledge` |

---

## 提测要点

1. **本地 lastUsedAt**：记录一次使用后，本地 DB `items.last_used_at` 立即更新，idle 列表应消失该物品
2. **历史回填**：`alembic upgrade head` 后，有使用记录的老物品 `last_used_at` 非空
3. **AI 文案**：服务端写入 `type=idle` 通知后，客户端通知中心 / 提醒卡描述应为 AI body（无网则本地默认文案）
4. **降级规则**：无 DEEPSEEK_KEY 时，洗衣液入库 10 天不提醒；牛奶 5 天提醒
5. **Celery**：`python -c "from app.tasks.scheduled_tasks import generate_idle_reminders"` 可正常 import

## 客户端效果预览（推荐）

不改服务端、不依赖 Celery，直接跑 Flutter 测试即可在终端看到提醒文案：

```bash
cd HomeWareClient
flutter test test/presentation/alerts/idle_reminder_effect_test.dart --reporter expanded
```

覆盖：
- 本地默认 idle 文案 / 紧急度
- AI `descriptionOverride` 覆盖
- 管管 `findIdleItems` / `buildIdleInsight`
- `AlertCard` Widget 渲染（标题、AI 文案、「已知晓」）
