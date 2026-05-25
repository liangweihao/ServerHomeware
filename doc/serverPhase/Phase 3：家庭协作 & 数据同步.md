# HomeStock Server — Phase 3：家庭协作 & 数据同步

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
- 退出后 current_family_id 置空
```

**PUT /api/v1/families/current/switch**
```
说明：切换当前家庭（如果用户属于多个家庭）
请求：{family_id}
逻辑：检查用户确实属于该家庭，更新 current_family_id
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
| 删除家庭 | ✅ | ❌ | ❌ |
| 修改家庭设置 | ✅ | ✅ | ❌ |

### 实现方式
创建权限检查依赖：
- require_member：只要是家庭成员即可
- require_admin：需要admin或owner角色
- require_owner：需要owner角色

在对应接口中注入权限依赖。

---

## 任务3：操作记录增强

### 完善 UsageRecord

所有操作自动记录 operator_id 和 operator_name（从当前登录用户获取）。

### ActivityLog 模型（新增，可选）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK | |
| user_id | Integer, FK | |
| action | String(50) | create_item/use_item/delete_item/... |
| target_type | String(50) | item/location/category/... |
| target_id | Integer | |
| target_name | String(100) | 冗余名称方便显示 |
| detail | JSON, nullable | 额外信息 |
| created_at | DateTime | |

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
      "created": [...],  // since 之后新建的
      "updated": [...],  // since 之后修改的
      "deleted": [id...] // since 之后删除的
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
  "conflicts": [...] // 冲突记录（服务端也改了）
}
逻辑：
- 逐条处理
- 如果某物品在App离线期间服务端也被修改（updated_at更新）→ 标记冲突
- 冲突策略：服务端数据优先，将冲突记录返回让App处理
```

### 软删除支持
为 Item、Location、Category 添加 deleted_at 字段：
- 删除时不真正删除，设 deleted_at = now
- 查询时默认过滤 deleted_at IS NULL
- 同步接口需要返回已删除的 ID 列表

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

## 验收标准

1. ✅ 创建家庭并自动生成邀请码
2. ✅ 通过邀请码成功加入家庭
3. ✅ 切换家庭后数据正确隔离
4. ✅ 权限控制生效：member不能删除物品
5. ✅ 所有操作正确记录operator_id
6. ✅ 动态流API返回正确的家庭操作记录
7. ✅ 增量同步接口正确返回变更数据
8. ✅ 批量推送接口正确处理并返回结果
9. ✅ 设备注册接口正常
10. ✅ 软删除机制正确（查询排除已删除，同步包含已删除ID）