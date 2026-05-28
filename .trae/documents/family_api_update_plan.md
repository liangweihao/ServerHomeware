# 家庭协作 API 更新计划

## 一、差异分析

根据设计文档 `Phase 3：家庭协作 & 数据同步.md`，当前实现存在以下缺失：

### 1. 缺少的接口

| 接口 | 方法 | 状态 | 说明 |
|------|------|------|------|
| `/api/v1/families/{family_id}` | DELETE | ❌ | 删除家庭（需名称确认） |
| `/api/v1/families/members/{member_id}` | DELETE | ❌ | 移除成员 |
| `/api/v1/families/{family_id}/transfer-ownership` | POST | ❌ | 转让所有权 |

### 2. 模型缺少字段

| 表 | 缺失字段 | 类型 | 说明 |
|----|----------|------|------|
| families | deleted_at | TIMESTAMP | 软删除标记 |
| families | icon | VARCHAR(10) | 家庭图标，默认 '🏠' |

### 3. GET /api/v1/families 返回数据缺失

设计文档要求返回：
- `role`: 当前用户在该家庭的角色
- `member_count`: 成员数量
- `item_count`: 物品数量
- `icon`: 家庭图标

当前返回：只有基础的家庭信息（id, name, invite_code, owner_id, created_at）

---

## 二、实现计划

### 任务 1：更新模型（models/family.py）

添加 `deleted_at` 和 `icon` 字段到 Family 模型

### 任务 2：更新 GET /api/v1/families 接口

增强返回数据，包含：
- role（当前用户角色）
- member_count（成员数）
- item_count（物品数）
- icon（家庭图标）

### 任务 3：实现 DELETE /api/v1/families/{family_id}

实现删除家庭功能，包含：
- 权限检查（仅 owner 可删除）
- 名称确认（需输入家庭名称）
- 不能删除当前家庭
- 不能删除最后一个家庭
- 级联软删除子数据

### 任务 4：实现 DELETE /api/v1/families/members/{member_id}

实现移除成员功能，包含：
- owner 可移除任何人
- admin 可移除 member（不能移除 owner）
- 不能移除自己

### 任务 5：实现 POST /api/v1/families/{family_id}/transfer-ownership

实现转让所有权功能：
- 当前 owner 降为 admin
- 目标成员升为 owner

### 任务 6：创建数据库迁移脚本

添加 deleted_at 和 icon 字段到 families 表

---

## 三、文件修改清单

| 文件路径 | 修改类型 | 说明 |
|----------|----------|------|
| `app/models/family.py` | 修改 | 添加 deleted_at, icon 字段 |
| `app/api/v1/families.py` | 修改 | 增强 GET /families，添加新接口 |
| `app/services/family_service.py` | 修改 | 添加删除、移除成员、转让所有权方法 |
| `app/schemas/family.py` | 修改 | 添加新的请求/响应 Schema |
| `alembic/versions/xxx_add_family_fields.py` | 新增 | 数据库迁移脚本 |

---

## 四、风险与依赖

### 依赖检查
1. 确保 Item、Location、Category 模型已支持软删除（deleted_at）
2. 确保 ActivityLog 服务可用，用于记录删除操作

### 风险点
1. 删除家庭的级联操作需要谨慎处理，确保数据完整性
2. 转让所有权后需要更新相关权限检查

---

## 五、验收标准

根据设计文档，需满足：
1. ✅ 删除家庭：owner 可删除、需名称确认、不能删当前家庭、不能删最后一个家庭
2. ✅ 删除家庭后级联软删除所有子数据
3. ✅ 删除家庭后其他成员自动切换到可用家庭
4. ✅ 转让所有权正常工作
5. ✅ GET /api/v1/families 返回完整数据（含 role, member_count, item_count）