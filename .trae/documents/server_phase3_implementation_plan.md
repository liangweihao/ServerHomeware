# Server Phase 3：家庭协作 & 数据同步 - 实现计划

## 1. 需求分析

根据文档 `/Users/lwh/Desktop/Project/ServerHomeWare/doc/serverPhase/Phase 3：家庭协作 & 数据同步.md`，需要实现以下功能：

| 任务 | 已有基础 | 需要新增/完善 |
|------|----------|---------------|
| 家庭管理 API | ✅ 创建/加入/切换/离开 | 刷新邀请码、获取当前家庭详情 |
| 权限控制 | ❌ | require_member/require_admin/require_owner |
| 操作记录增强 | ✅ UsageRecord | ActivityLog 模型、动态流 API |
| 数据同步机制 | ❌ | 增量同步、批量推送、软删除 |
| 设备管理 | ❌ | UserDevice 模型、设备注册/注销 |

## 2. 核心实现内容

### 2.1 权限控制

| 权限依赖 | 角色要求 | 适用场景 |
|----------|----------|----------|
| require_member | 任意家庭成员 | 查看物品、记录使用 |
| require_admin | admin 或 owner | 删除物品、管理位置/分类 |
| require_owner | owner 角色 | 删除家庭、转让所有权 |

### 2.2 操作记录增强

**ActivityLog 模型字段：**
- id, family_id, user_id, action, target_type, target_id, target_name, detail, created_at

**动态流 API：**
- GET /api/v1/activities - 获取家庭动态流

### 2.3 数据同步机制

**增量同步接口：**
- GET /api/v1/sync/changes?since=timestamp
- 返回：server_time, changes(items/categories/locations/shopping_list)

**批量推送接口：**
- POST /api/v1/sync/push
- 处理离线操作，返回结果和冲突

### 2.4 设备管理

**UserDevice 模型字段：**
- id, user_id, device_token, device_type, device_name, last_active_at, created_at

## 3. 文件修改计划

### 3.1 新增文件

| 文件路径 | 说明 |
|----------|------|
| `app/models/activity_log.py` | ActivityLog 模型 |
| `app/models/user_device.py` | UserDevice 模型 |
| `app/repositories/activity_log_repo.py` | 活动日志仓库 |
| `app/repositories/user_device_repo.py` | 设备仓库 |
| `app/services/activity_service.py` | 活动服务 |
| `app/api/v1/activities.py` | 动态流 API |
| `app/api/v1/sync.py` | 数据同步 API |
| `app/api/v1/devices.py` | 设备管理 API |

### 3.2 修改文件

| 文件路径 | 修改内容 |
|----------|----------|
| `app/core/dependencies.py` | 添加权限检查依赖 |
| `app/api/v1/families.py` | 添加刷新邀请码、获取当前家庭 |
| `app/models/item.py` | 添加 deleted_at 字段 |
| `app/models/location.py` | 添加 deleted_at 字段 |
| `app/models/category.py` | 添加 deleted_at 字段 |

## 4. 实现步骤

### 步骤 1：添加权限检查依赖

```python
# 在 dependencies.py 中添加：
async def require_member(user, db): ...
async def require_admin(user, db): ...
async def require_owner(user, db): ...
```

### 步骤 2：创建 ActivityLog 模型和仓库

```python
# ActivityLog 模型
class ActivityLog(Base, BaseMixin):
    __tablename__ = "activity_logs"
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    action = Column(String(50), nullable=False)  # create_item/use_item/...
    target_type = Column(String(50))
    target_id = Column(Integer)
    target_name = Column(String(100))
    detail = Column(JSON)
```

### 步骤 3：创建动态流 API

```python
# GET /api/v1/activities
# 返回：分页的动态列表
```

### 步骤 4：实现软删除机制

```python
# 在 Item、Location、Category 模型中添加：
deleted_at = Column(DateTime, nullable=True)

# 在仓库中添加软删除方法
async def soft_delete(self, id, family_id): ...
```

### 步骤 5：创建数据同步 API

```python
# GET /api/v1/sync/changes?since=...
# POST /api/v1/sync/push
```

### 步骤 6：创建设备管理 API

```python
# POST /api/v1/devices/register
# DELETE /api/v1/devices/{id}
```

### 步骤 7：完善家庭管理 API

```python
# POST /api/v1/families/current/refresh-invite-code
# GET /api/v1/families/current
```

## 5. 代码规范

遵循 `/Users/lwh/Desktop/Project/ServerHomeWare/doc/rules/codestyle.mdc`：
- ✅ 新增代码添加注释/注解
- ✅ 核心业务代码添加日志
- ✅ 保持文档与代码一致

## 6. 验收标准

| 验收项 | 验证方式 |
|--------|----------|
| 创建家庭并生成邀请码 | POST /api/v1/families |
| 通过邀请码加入家庭 | POST /api/v1/families/join |
| 切换家庭后数据隔离 | POST /api/v1/families/{id}/switch |
| 权限控制生效 | 测试 member 不能删除物品 |
| 动态流 API | GET /api/v1/activities |
| 增量同步接口 | GET /api/v1/sync/changes |
| 批量推送接口 | POST /api/v1/sync/push |
| 设备注册接口 | POST /api/v1/devices/register |
| 软删除机制 | 删除物品后检查 deleted_at |
