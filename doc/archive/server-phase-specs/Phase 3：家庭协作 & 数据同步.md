# HomeStock Server — Phase 3：家庭协作 & 数据同步（修订版）

## 前置条件
Phase 1-2 已完成。认证系统和核心CRUD API就绪。

## 本阶段目标
实现家庭多人协作：邀请成员、权限管理、操作记录归属、数据变更同步机制。

---

## 任务1：家庭管理 API

**POST /api/v1/families**
```
说明：创建新家庭
请求：{name}
逻辑：
- 创建家庭，owner_id=当前用户
- 生成8位随机邀请码（字母+数字，避免歧义字符）
- 创建 family_member 记录（role=owner）
- 从预设模板复制位置结构到新家庭
- 更新用户 current_family_id
```

**GET /api/v1/families/current**
```
说明：获取当前家庭信息
响应：家庭基础信息 + 成员列表 + 邀请码 + 统计数据（物品总数等）
```

**GET /api/v1/families**
```
说明：获取用户所属的所有家庭列表
响应：
{
  "current_family_id": 1,
  "families": [
    {
      "id": 1,
      "name": "温馨小窝",
      "icon": "🏠",
      "member_count": 3,
      "item_count": 95,
      "role": "owner",
      "created_at": "2024-01-15T08:00:00Z"
    },
    ...
  ]
}
```

**POST /api/v1/families/join**
```
说明：通过邀请码加入家庭
请求：{invite_code}
逻辑：
- 查找邀请码对应的家庭
- 检查用户是否已在该家庭
- 创建 family_member（role=member）
- 更新用户 current_family_id
```

**POST /api/v1/families/current/refresh-invite-code**
```
说明：刷新邀请码（仅owner/admin）
逻辑：生成新邀请码替换旧的
```

**PUT /api/v1/families/{family_id}**
```
说明：更新家庭信息（owner/admin 可操作）
请求：{name}
逻辑：
- 鉴权：用户须为该家庭成员，且 role 为 owner 或 admin
- 更新家庭名称（1–50 字符）
```

**PUT /api/v1/families/members/{member_id}/role**
```
说明：修改成员角色（仅owner可操作）
请求：{role: "admin" | "member"}
```

**DELETE /api/v1/families/members/{member_id}**
```
说明：移除成员（owner可移除任何人；admin可移除member；不能移除自己）
```

**POST /api/v1/families/leave**
```
说明：主动退出家庭
逻辑：
- owner不能退出（需先转让）
- 退出后 current_family_id 置空或切换到用户的其他家庭
```

**PUT /api/v1/families/switch**
```
说明：切换当前家庭（如果用户属于多个家庭）
请求：{family_id}
逻辑：检查用户确实属于该家庭，更新 current_family_id
响应：
{
  "message": "已切换到「老家」",
  "current_family": { ...新家庭完整信息 }
}
```

**DELETE /api/v1/families/{family_id}**
```
说明：删除家庭（仅owner可操作）
请求：{confirm_name}  ← 需要用户输入家庭名称作为二次确认
逻辑：
- 鉴权：仅 owner 角色可执行
- 校验 confirm_name 与家庭实际名称完全匹配，不匹配返回 400
- 若删除的是 current_family_id，服务端自动将用户切换到其另一个可用家庭；若无其他家庭则置空
- 软删除家庭：设置 families.deleted_at = now
- 级联软删除该家庭下所有数据：
  - items.deleted_at = now
  - locations.deleted_at = now
  - categories.deleted_at = now（家庭自定义分类）
  - shopping_list_items.deleted_at = now
  - usage_records 保留不删（历史归档）
- 删除所有 family_member 关联记录
- 其他成员的 current_family_id 如果指向该家庭，置为他们的下一个可用家庭或 null
- 记录 ActivityLog（action="delete_family"）

错误响应：
- 403：非owner身份
- 400 "confirm_name_mismatch"：输入名称不匹配
```

**POST /api/v1/families/{family_id}/transfer-ownership**
```
说明：转让家庭所有权（仅owner可操作）
请求：{new_owner_id}
逻辑：
- 当前owner降为admin
- 目标成员升为owner
- 记录 ActivityLog
```

---

## 任务2：权限控制

### 角色权限矩阵

| 操作 | owner | admin | member |
|------|-------|-------|--------|
| 查看物品/位置/分类 | ✅ | ✅ | ✅ |
| 添加/编辑物品 | ✅ | ✅ | ✅ |
| 记录使用 | ✅ | ✅ | ✅ |
| 删除物品 | ✅ | ✅ | ❌ |
| 管理位置 | ✅ | ✅ | ❌ |
| 管理分类 | ✅ | ✅ | ❌ |
| 管理成员 | ✅ | ✅（不能改owner） | ❌ |
| **删除家庭** | ✅ | ❌ | ❌ |
| **转让所有权** | ✅ | ❌ | ❌ |
| 修改家庭设置 | ✅ | ✅ | ❌ |
| 刷新邀请码 | ✅ | ✅ | ❌ |

### 实现方式
创建权限检查依赖：
- `require_member`：只要是家庭成员即可
- `require_admin`：需要admin或owner角色
- `require_owner`：需要owner角色

在对应接口中注入权限依赖。

---

## 任务3：操作记录增强

### 完善 UsageRecord

所有操作自动记录 operator_id 和 operator_name（从当前登录用户获取）。

### ActivityLog 模型（新增）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK | |
| user_id | Integer, FK | |
| action | String(50) | create_item/use_item/delete_item/delete_family/... |
| target_type | String(50) | item/location/category/family/... |
| target_id | Integer | |
| target_name | String(100) | 冗余名称方便显示 |
| detail | JSON, nullable | 额外信息 |
| created_at | DateTime | |

### action 枚举值

| action | 说明 |
|--------|------|
| create_item | 新建物品 |
| update_item | 修改物品 |
| delete_item | 删除物品 |
| use_item | 使用/消耗物品 |
| create_location | 新建位置 |
| delete_location | 删除位置 |
| create_family | 创建家庭 |
| **delete_family** | 删除家庭 |
| join_family | 加入家庭 |
| leave_family | 退出家庭 |
| remove_member | 移除成员 |
| change_role | 修改角色 |
| transfer_ownership | 转让所有权 |
| switch_family | 切换家庭 |

### 动态流 API

**GET /api/v1/activities**
```
说明：获取家庭动态流（首页"最近动态"数据源）
查询参数：page, page_size, user_id(可选，筛选某人的操作)
响应：分页的动态列表，每条含：操作人名称、操作描述、时间、目标物品
```

---

## 任务4：数据同步机制

### 方案：增量同步（基于 updated_at 时间戳）

Flutter App 端记录上次同步时间（last_sync_at），请求时带上。

**GET /api/v1/sync/changes**
```
查询参数：since（ISO时间戳，上次同步时间）
响应：
{
  "server_time": "2024-01-25T10:00:00Z",
  "changes": {
    "items": {
      "created": [...],
      "updated": [...],
      "deleted": [id...]
    },
    "categories": { ... },
    "locations": { ... },
    "shopping_list": { ... }
  }
}
逻辑：查询 updated_at > since 或 deleted_at > since 的记录
```

**POST /api/v1/sync/push**
```
说明：App端离线操作后批量上传
请求：
{
  "items": [
    {"action": "create", "data": {...}, "client_id": "temp_123"},
    {"action": "update", "data": {...}, "id": 45},
    {"action": "delete", "id": 46}
  ],
  "usage_records": [...]
}
响应：
{
  "results": [
    {"client_id": "temp_123", "server_id": 78, "status": "ok"},
    ...
  ],
  "conflicts": [...]
}
逻辑：
- 逐条处理
- 冲突策略：服务端数据优先，冲突记录返回让App处理
```

### 软删除支持
为 Item、Location、Category、**Family** 添加 deleted_at 字段：
- 删除时不真正删除，设 deleted_at = now
- 查询时默认过滤 deleted_at IS NULL
- 同步接口需要返回已删除的 ID 列表
- Family 软删除后，其邀请码失效（加入时需检查 deleted_at IS NULL）

---

## 任务5：设备管理

### UserDevice 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| user_id | Integer, FK → users | |
| device_token | String(500) | FCM推送token |
| device_type | String(20) | ios/android |
| device_name | String(100), nullable | 如"iPhone 15" |
| last_active_at | DateTime | |
| created_at | DateTime | |

**POST /api/v1/devices/register**
```
请求：{device_token, device_type, device_name}
逻辑：注册/更新设备token（用于推送通知）
```

**DELETE /api/v1/devices/{id}**
```
说明：注销设备（退出登录时调用）
```

---

## 数据库变更（本阶段新增/修改）

### 新增字段
```sql
-- families 表新增
ALTER TABLE families ADD COLUMN deleted_at TIMESTAMP NULL;
ALTER TABLE families ADD COLUMN icon VARCHAR(10) DEFAULT '🏠';

-- items 表新增
ALTER TABLE items ADD COLUMN deleted_at TIMESTAMP NULL;

-- locations 表新增
ALTER TABLE locations ADD COLUMN deleted_at TIMESTAMP NULL;

-- categories 表新增
ALTER TABLE categories ADD COLUMN deleted_at TIMESTAMP NULL;
```

### 新增表
```sql
-- activity_logs
-- user_devices
-- （结构见上方模型定义）
```

### 新增索引
```sql
CREATE INDEX idx_families_deleted_at ON families(deleted_at);
CREATE INDEX idx_items_deleted_at ON items(deleted_at);
CREATE INDEX idx_activity_logs_family_created ON activity_logs(family_id, created_at DESC);
```

---

## 验收标准

1. ✅ 创建家庭并自动生成邀请码
2. ✅ 通过邀请码成功加入家庭
3. ✅ 获取用户所有家庭列表
4. ✅ 切换家庭后数据正确隔离
5. ✅ 权限控制生效：member不能删除物品
6. ✅ **删除家庭：owner可删除、需名称确认、可删当前/唯一家庭（自动切换或置空 current_family_id）**
7. ✅ **删除家庭后级联软删除所有子数据**
8. ✅ **删除家庭后其他成员自动切换到可用家庭**
9. ✅ **转让所有权正常工作**
10. ✅ 所有操作正确记录operator_id
11. ✅ 动态流API返回正确的家庭操作记录
12. ✅ 增量同步接口正确返回变更数据
13. ✅ 批量推送接口正确处理并返回结果
14. ✅ 设备注册接口正常
15. ✅ 软删除机制正确（查询排除已删除，同步包含已删除ID）
16. ✅ 已删除家庭的邀请码不可再使用

---

## 修订记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | - | 初始版本 |
| **v1.1** | - | 新增 DELETE /api/v1/families/{family_id} 删除家庭接口；新增 GET /api/v1/families 家庭列表接口；新增 POST transfer-ownership 转让接口；families 表增加 deleted_at 和 icon 字段；完善验收标准 |