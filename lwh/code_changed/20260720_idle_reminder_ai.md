# 物品遗忘提醒 + AI 智能提醒

**日期**：2026-07-20  
**模块**：server + client  
**状态**：已完成

---

## 一、需求背景

用户买了物品后长时间未使用可能遗忘，需要智能提醒。由 DeepSeek 根据物品分类、季节等信息判断合理提醒时机，Celery Beat 定时生成，客户端整合进现有通知中心体系。

---

## 二、实现方案

### 数据流

```
每天 03:30 Celery Beat
  → generate_idle_reminders()
  → 查 Item.last_used_at（或 created_at）
  → 筛选候选物品（入库 7 天未用 或 30 天未用）
  → 打包 prompt → DeepSeek API
  → 解析 JSON → upsert Notification(type='idle')

客户端打开 / 同步
  → 本地 getIdleAlerts() 检测（同步策略：lastUsedAt < 30天 或 createdAt < 7天）
  → _collectAllAlertPairs() 覆盖 idle 类型
  → unreadAlertCountProvider Badge 更新
  → NotificationCenterPage 展示 idle 提醒行（图标+文案，可点击跳转详情）
```

---

## 三、改动点

### 服务端

| 文件 | 改动 |
|------|------|
| `app/models/item.py` | 新增 `last_used_at: DateTime nullable` 字段 |
| `alembic/versions/0012_add_last_used_at_to_items.py` | 新增 Alembic 迁移文件 |
| `app/api/v1/usage_records.py` | 创建 `type=1` 记录时同步更新 `item.last_used_at` |
| `app/schemas/item.py` | `ItemResponse` 新增 `last_used_at: Optional[datetime]` |
| `app/models/notification.py` | 新增常量 `TYPE_IDLE = "idle"` |
| `app/tasks/scheduled_tasks.py` | 新增 `generate_idle_reminders()` 任务、`_call_deepseek_sync()`、`_build_idle_prompt()`、`_get_current_season()` 辅助函数 |
| `app/tasks/celeryconfig.py` | 新增 `generate-idle-reminders-daily`（每天 03:30） |

### 客户端

| 文件 | 改动 |
|------|------|
| `lib/data/database/app_database.dart` | `Items` 表新增 `lastUsedAt` 列；`schemaVersion → 8`；`migration v7→v8`；新增 `getIdleAlerts()` 方法；`_collectAllAlertPairs()` 覆盖 idle |
| `lib/core/services/item_sync_service.dart` | `_serverItemToCompanion` 和 `syncFromServer` 同步 `last_used_at → lastUsedAt` |
| `lib/core/models/alert_type.dart` | 枚举新增 `idle` |
| `lib/core/utils/alert_display_helper.dart` | `alertTypeToKey`/`alertTypeFromKey`/`getAlertDisplayInfo` 三处 switch 补充 `idle` 分支（图标 😴、颜色 textHint、urgency 按天数分级） |
| `lib/core/assistant/guanguan_panel_builder.dart` | 新增 `findIdleItems()` 返回物品列表；`buildIdleInsight()` 升级返回 `({String text, int itemId})?` |
| `lib/core/assistant/guanguan_panel_models.dart` | `idleInsight` 字段类型升级为 `({String text, int itemId})?` |
| `lib/presentation/home/widgets/guanguan_panel_card.dart` | `_InsightLine` 接收新类型，新增点击跳转物品详情 + 右箭头图标 |
| `lib/presentation/alerts/widgets/alert_card.dart` | switch 新增 `AlertType.idle` 分支（归入"已知晓"操作） |

---

## 四、AI 判断规则（DeepSeek prompt）

| 分类 | 提醒阈值 |
|------|---------|
| 食材/生鲜 | 3 天 |
| 日常消耗品（洗发水/牙膏等） | 14 天 |
| 清洁/卫生用品 | 60 天 |
| 季节性物品 | 结合当季判断 |
| 电子产品/设备 | 90 天 |
| 其他 | 30 天 |

AI 不可用时降级到默认规则（idle_days 天未使用 → 固定文案）。

---

## 五、测试点

### 服务端
1. 记录一次 `type=1` UsageRecord，验证 `items.last_used_at` 被更新
2. 手动调用 `generate_idle_reminders.delay()`，验证 `notifications` 表出现 `type='idle'` 记录
3. DEEPSEEK_API_KEY 未配置时任务正常完成（按分类阈值降级，非全量提醒）
4. 候选物品为空的家庭直接跳过，无 DB 写入
5. `alembic upgrade head` 含 `0013_backfill_last_used_at`，有历史使用记录的物品 `last_used_at` 非空

### 客户端
1. 本地物品 `lastUsedAt` 超 30 天 → `getIdleAlerts()` 返回该物品
2. 本地写入 type=1 使用记录后，`lastUsedAt` 立即更新，idle 提醒消失
3. 通知中心展示 idle 类型行；有服务端 AI body 时优先展示 AI 文案
4. 点击 idle 提醒行跳转到物品详情页
5. 标记全部已读 / idle「已知晓」后 Badge 数字归零
6. 同步服务端数据后 `lastUsedAt` 正确写入本地

### 注意事项
- Alembic：`0012_add_last_used_at` + `0013_backfill_last_used_at`；客户端 schemaVersion=8
- 产品策略：本地检测决定「提醒谁」，服务端 AI body 覆盖「说什么」
- 详见 `20260720_idle_reminder_review_fixes.md`
