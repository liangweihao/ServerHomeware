# Server Phase 4：提醒 & 推送 & 定时任务 - 实现计划

## 1. 需求分析

根据文档和代码探索，本阶段需要实现提醒检查、推送通知、定时任务系统。

### 当前已有功能

| 功能 | 文件 | 状态 |
|------|------|------|
| Celery 基础配置 | `app/tasks/celery_app.py` | ✅ 已完成 |
| Notification 模型 | `app/models/notification.py` | ✅ 已完成 |
| NotificationPreference 模型 | `app/models/notification_preference.py` | ✅ 已完成 |
| NotificationRepository | `app/repositories/notification_repo.py` | ✅ 已完成 |
| PushService + SyncPushService | `app/services/push_service.py` | ✅ 已完成 |
| 过期检查占位符 | `app/tasks/expiry_check.py` | ⚠️ 仅占位 |

### 待实现功能

| 功能 | 说明 |
|------|------|
| NotificationService | 通知服务层，整合推送和存储 |
| Notification API | 通知列表/未读数/标记已读/删除 |
| 用户通知偏好 API | 获取/更新用户偏好设置 |
| 增强提醒摘要 API | 添加 nearest_expiry, nearest_empty |
| Celery 定时任务 | 过期检查/自动更新/购物推荐/清理 |
| Celery Beat 配置 | 定时调度配置 |
| 数据库迁移 | 创建 notification 相关表 |

---

## 2. 文件清单

### 2.1 新增文件

| 文件路径 | 说明 |
|----------|------|
| `app/services/notification_service.py` | 通知服务，整合通知存储和推送 |
| `app/api/v1/notifications.py` | 通知 API 端点 |
| `app/schemas/notification.py` | 通知 Pydantic Schema |
| `app/schemas/notification_preference.py` | 偏好设置 Schema |
| `app/tasks/scheduled_tasks.py` | Celery 定时任务实现 |
| `app/tasks/celeryconfig.py` | Celery Beat 调度配置 |

### 2.2 修改文件

| 文件路径 | 修改内容 |
|----------|----------|
| `app/api/v1/users.py` | 添加通知偏好获取/更新端点 |
| `app/api/v1/alerts.py` | 增强 summary 接口，添加 expiring/low-stock 端点 |
| `app/api/v1/__init__.py` | 注册 notifications_router |
| `app/api/router.py` | 注册 notifications_router |
| `app/tasks/expiry_check.py` | 删除占位文件，任务移至 scheduled_tasks.py |

### 2.3 数据库迁移

需要在 `alembic` 目录下创建迁移文件（如果 alembic 未初始化，则需先初始化）。

---

## 3. 详细实现步骤

### 步骤 1：创建通知 Schema

**文件**: `app/schemas/notification.py`

```python
class NotificationResponse(BaseModel):
    """通知响应Schema"""
    id: int
    family_id: int
    user_id: Optional[int]
    type: str
    title: str
    body: Optional[str]
    item_id: Optional[int]
    priority: str
    is_read: bool
    action_url: Optional[str]
    created_at: datetime

class NotificationListResponse(BaseModel):
    """通知列表响应（分页）"""
    items: List[NotificationResponse]
    total: int
    page: int
    page_size: int
    pages: int

class UnreadCountResponse(BaseModel):
    """未读数量响应"""
    count: int
```

**文件**: `app/schemas/notification_preference.py`

```python
class NotificationPreferenceResponse(BaseModel):
    """通知偏好响应"""
    push_enabled: bool
    expiry_alert: bool
    stock_alert: bool
    purchase_alert: bool
    warranty_alert: bool
    quiet_start: Optional[time]
    quiet_end: Optional[time]

class UpdateNotificationPreferenceRequest(BaseModel):
    """更新通知偏好请求"""
    push_enabled: Optional[bool]
    expiry_alert: Optional[bool]
    stock_alert: Optional[bool]
    purchase_alert: Optional[bool]
    warranty_alert: Optional[bool]
    quiet_start: Optional[time]
    quiet_end: Optional[time]
```

### 步骤 2：创建通知服务

**文件**: `app/services/notification_service.py`

```python
class NotificationService:
    """通知服务"""

    async def create_notification(
        self,
        family_id: int,
        notification_type: str,
        title: str,
        body: str,
        user_id: Optional[int] = None,
        item_id: Optional[int] = None,
        priority: str = "medium",
        action_url: Optional[str] = None
    ) -> Notification

    async def get_notifications(
        self,
        family_id: int,
        user_id: Optional[int] = None,
        notification_type: Optional[str] = None,
        is_read: Optional[bool] = None,
        page: int = 1,
        page_size: int = 20
    ) -> Dict

    async def get_unread_count(self, family_id: int, user_id: Optional[int] = None) -> int

    async def mark_read(self, notification_id: int, family_id: int) -> bool

    async def mark_all_read(self, family_id: int, user_id: Optional[int] = None) -> int

    async def delete_notification(self, notification_id: int, family_id: int) -> bool

    async def should_send_notification(
        self,
        user_id: int,
        notification_type: str
    ) -> Tuple[bool, str]:
        """检查是否应发送通知，考虑用户偏好和免打扰时段"""
```

**关键逻辑**:
- 创建通知后，调用 `PushService.push_to_user` 或 `push_to_family` 发送推送
- 发送前检查用户通知偏好设置
- 检查免打扰时段，如果正在免打扰则跳过或延迟
- 使用 Redis 记录当天已发送的通知进行去重

### 步骤 3：创建通知 API

**文件**: `app/api/v1/notifications.py`

```python
router = APIRouter(prefix="/notifications", tags=["notifications"])

@router.get("", summary="获取通知列表")
async def get_notifications(
    type: Optional[str] = Query(None),
    is_read: Optional[bool] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.get("/unread-count", summary="获取未读通知数量")
async def get_unread_count(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.put("/{notification_id}/read", summary="标记通知已读")
async def mark_notification_read(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.put("/read-all", summary="标记所有通知已读")
async def mark_all_notifications_read(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.delete("/{notification_id}", summary="删除通知")
async def delete_notification(
    notification_id: int,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)
```

### 步骤 4：更新用户 API 添加通知偏好

**文件**: `app/api/v1/users.py` 添加

```python
@router.get("/me/notification-preferences", summary="获取通知偏好")
async def get_notification_preferences(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
)

@router.put("/me/notification-preferences", summary="更新通知偏好")
async def update_notification_preferences(
    request: UpdateNotificationPreferenceRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
)
```

### 步骤 5：增强提醒摘要 API

**文件**: `app/api/v1/alerts.py` 修改/添加

现有 `/alerts/summary` 接口需要增强返回：

```python
class AlertSummaryEnhancedResponse(BaseModel):
    expiring_count: int      # 7天内过期数量
    expired_count: int       # 已过期未处理
    low_stock_count: int     # 库存不足
    shopping_count: int      # 待购数量
    nearest_expiry: Optional[Dict]  # 最近要过期的物品
    nearest_empty: Optional[Dict]   # 最近要用完的物品
```

添加新端点：

```python
@router.get("/expiring", summary="获取即将过期物品列表")
async def get_expiring_items(
    days: int = Query(7, ge=1, le=30),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.get("/low-stock", summary="获取库存不足物品列表")
async def get_low_stock_items(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)
```

### 步骤 6：实现 Celery 定时任务

**文件**: `app/tasks/scheduled_tasks.py`

```python
@celery.task
def check_expiry():
    """
    每天早上8:00执行
    检查即将过期物品并发送通知
    """
    # 1. 查询所有 status=0 且 expiry_date 不为空 的物品
    # 2. 对每个物品计算 days_until_expiry
    # 3. 如果 days_until_expiry <= expiry_alert_days：
    #    - 生成通知记录
    #    - 发送推送通知
    # 4. 去重：同一个物品当天只推送一次

@celery.task
def auto_expire_items():
    """
    每天凌晨1:00执行
    自动将已过期物品状态改为2
    """
    # UPDATE items SET status=2, updated_at=now
    # WHERE status=0 AND expiry_date < today

@celery.task
def generate_shopping_suggestions():
    """
    每天早上9:00执行
    自动生成购物推荐到购物清单
    """
    # 遍历所有 status=0 的物品
    # IF (current_quantity <= safety_stock) OR (predicted_empty_date <= today + 7天)
    # AND shopping_list 中不存在该物品的未购买记录
    # THEN: INSERT shopping_list（is_auto_generated=True）

@celery.task
def update_predictions():
    """
    每天凌晨2:00执行
    批量更新消耗预测
    """
    pass  # 预留接口，根据业务需求实现

@celery.task
def clean_old_notifications():
    """
    每周日凌晨3:00执行
    清理30天前的通知记录
    """
    # 调用 NotificationRepository.delete_old(30)
```

### 步骤 7：配置 Celery Beat

**文件**: `app/tasks/celeryconfig.py`

```python
from celery.schedules import crontab

CELERYBEAT_SCHEDULE = {
    'check-expiry-daily': {
        'task': 'app.tasks.scheduled_tasks.check_expiry',
        'schedule': crontab(hour=8, minute=0),
    },
    'auto-expire-items-daily': {
        'task': 'app.tasks.scheduled_tasks.auto_expire_items',
        'schedule': crontab(hour=1, minute=0),
    },
    'update-predictions-daily': {
        'task': 'app.tasks.scheduled_tasks.update_predictions',
        'schedule': crontab(hour=2, minute=0),
    },
    'generate-shopping-suggestions-daily': {
        'task': 'app.tasks.scheduled_tasks.generate_shopping_suggestions',
        'schedule': crontab(hour=9, minute=0),
    },
    'clean-old-notifications-weekly': {
        'task': 'app.tasks.scheduled_tasks.clean_old_notifications',
        'schedule': crontab(hour=3, minute=0, day_of_week=0),
    },
}
```

**文件**: `app/tasks/celery_app.py` 添加导入

```python
celery.config_from_object('app.tasks.celeryconfig')
```

### 步骤 8：注册新路由

**文件**: `app/api/v1/__init__.py` 添加

```python
from app.api.v1.notifications import router as notifications_router

__all__ = [
    ...
    "notifications_router",
]
```

**文件**: `app/api/router.py` 添加

```python
from app.api.v1 import notifications_router

api_router.include_router(notifications_router)
```

### 步骤 9：创建数据库迁移

如果 `alembic` 已初始化：

```bash
cd /Users/lwh/Desktop/Project/ServerHomeWare
alembic revision --autogenerate -m "Add notification and notification_preference tables"
```

如果未初始化，需要先创建 alembic 环境：

```bash
cd HomeWareServer
alembic init alembic
```

然后创建迁移文件 `alembic/versions/xxx_add_notification_tables.py`。

---

## 4. 代码规范

遵循 `/Users/lwh/Desktop/Project/ServerHomeWare/doc/rules/codestyle.mdc`：

- ✅ 所有新增代码添加注释/注解
- ✅ 核心业务代码（服务层、任务）添加日志
- ✅ 关键流程：INFO 日志
- ✅ 异常/WARN 情况：WARNING/ERROR 日志

---

## 5. 验收标准

| 验收项 | 验证方式 |
|--------|----------|
| NotificationService 正常工作 | 单元测试或手动调用 |
| 通知 API 正常 | GET/PUT/DELETE /api/v1/notifications |
| 未读数接口正常 | GET /api/v1/notifications/unread-count |
| 通知偏好 API 正常 | GET/PUT /api/v1/users/me/notification-preferences |
| 增强提醒摘要 API 正常 | GET /api/v1/alerts/summary |
| 即将过期/低库存接口正常 | GET /api/v1/alerts/expiring, /low-stock |
| Celery Beat 配置正确 | 检查 celeryconfig.py |
| 数据库迁移文件创建 | 检查 alembic/versions 目录 |
| 路由正确注册 | 启动应用后检查 /docs |

---

## 6. 注意事项

1. **FCM 配置**: 需要设置有效的 `FCM_SERVER_KEY` 才能发送推送
2. **免打扰时段**: 推送前必须检查用户偏好和免打扰时段
3. **去重逻辑**: 使用 Redis 或数据库记录当天已发送通知
4. **异步任务**: Celery 任务使用 `SyncPushService` 进行同步数据库操作
5. **时间时区**: 所有时间使用 Asia/Shanghai 时区
