# Phase 2 核心数据模型 & CRUD API - 验证计划

## 一、项目现状分析

### 已完成的功能模块

| 模块 | 状态 | 说明 |
|------|------|------|
| 数据模型 | ✅ | Category、Location、Item、ItemImage、UsageRecord、ShoppingItem 已完整实现 |
| 数据库迁移 | ✅ | 包含所有表结构和索引的迁移脚本已创建 |
| Repository 层 | ✅ | BaseRepository + 各业务 Repository 已实现 |
| Service 层 | ✅ | CategoryService、LocationService、ItemService 已实现 |
| API 层 | ✅ | categories、locations、items 路由已完整实现 |
| Schemas | ✅ | 请求/响应模型已定义 |
| 种子数据脚本 | ✅ | seed_data.py 已创建 |

### 需要验证和完善的内容

1. **代码风格规范**：确保所有代码符合 codestyle.mdc 规范
2. **日志规范**：检查核心业务代码是否添加了必要日志
3. **预设数据完整性**：验证种子数据脚本能否正确执行
4. **接口验证**：确保所有 CRUD 接口正常工作

---

## 二、验证计划

### 任务1：代码风格检查

**目标**：确保代码符合 codestyle.mdc 规范

**检查内容**：
- [ ] 所有新增代码有注释/注解
- [ ] 核心业务代码有日志记录（关键流程/WARN/ERROR）
- [ ] 代码格式符合 PEP8 标准

**涉及文件**：
- `app/services/*.py`
- `app/api/v1/*.py`
- `app/repositories/*.py`
- `app/models/*.py`

---

### 任务2：验证数据库迁移

**目标**：确保迁移脚本能正确执行

**步骤**：
1. 检查迁移脚本完整性
2. 执行迁移命令验证

**命令**：
```bash
cd HomeWareServer
source .venv/bin/activate
alembic upgrade head
```

---

### 任务3：验证种子数据脚本

**目标**：确保预设分类和位置模板能正确初始化

**步骤**：
1. 检查 seed_data.py 脚本
2. 执行脚本验证系统分类初始化
3. 验证家庭创建时位置模板复制功能

**命令**：
```bash
cd HomeWareServer
source .venv/bin/activate
python scripts/seed_data.py
```

---

### 任务4：API 接口测试

**目标**：验证所有 CRUD 接口正常工作

**测试接口清单**：

| API 路径 | 方法 | 测试内容 |
|----------|------|----------|
| `/api/v1/categories` | GET | 获取树形分类列表 |
| `/api/v1/categories` | POST | 创建自定义分类 |
| `/api/v1/categories/{id}` | PUT | 更新分类 |
| `/api/v1/categories/{id}` | DELETE | 删除分类（系统分类不可删） |
| `/api/v1/locations` | GET | 获取树形位置列表 |
| `/api/v1/locations` | POST | 创建位置 |
| `/api/v1/locations/{id}` | PUT | 更新位置 |
| `/api/v1/locations/{id}` | DELETE | 删除位置（有物品不可删） |
| `/api/v1/items` | GET | 分页查询 + 筛选 + 排序 |
| `/api/v1/items` | POST | 创建物品 |
| `/api/v1/items/{id}` | GET | 获取物品详情（含图片和使用记录） |
| `/api/v1/items/{id}` | PUT | 更新物品 |
| `/api/v1/items/{id}` | DELETE | 删除物品 |
| `/api/v1/items/{id}/use` | POST | 记录物品使用 |
| `/api/v1/items/{id}/finish` | POST | 标记用完 |
| `/api/v1/items/{id}/discard` | POST | 标记丢弃 |
| `/api/v1/items/{id}/move` | POST | 移动物品位置 |
| `/api/v1/items/barcode/{barcode}` | GET | 条码查询 |

---

### 任务5：数据隔离验证

**目标**：确保 family_id 数据隔离生效

**验证点**：
- [ ] 不同家庭用户只能访问自己家庭的数据
- [ ] 系统预设分类对所有家庭可见（family_id=None）
- [ ] 创建数据时自动关联当前家庭

---

### 任务6：Swagger 文档验证

**目标**：确保 API 文档清晰可读

**验证点**：
- [ ] 所有接口都有 summary 说明
- [ ] 请求参数和响应结构清晰
- [ ] 枚举值有说明

---

## 三、潜在问题检查

### 检查项清单

| 检查项 | 描述 | 状态 |
|--------|------|------|
| CategoryService.get_categories_tree | 返回树形结构时是否包含 is_system 字段 | ✅ |
| LocationService.create_location | 层级限制是否正确（最大3层） | ✅ |
| LocationService.update_location | 更新名称时是否更新子位置的 full_path | ✅ |
| ItemService.create_item | 是否自动计算 expiry_date 和 total_price | ✅ |
| ItemService.use_item | 是否正确更新 avg_daily_consumption | ✅ |
| 软删除实现 | categories/locations 是否使用软删除 | ✅ |

---

## 四、代码优化建议

### 1. Schema 完善
- LocationResponse 需要添加 `level`、`full_path`、`sort_order`、`is_active` 字段
- CategoryResponse 需要添加 `sort_order`、`is_system`、`is_active` 字段

### 2. 日志增强
- 在关键业务操作处添加日志记录

### 3. 错误处理增强
- 添加更详细的错误信息

---

## 五、执行顺序

1. 任务1：代码风格检查
2. 任务2：数据库迁移验证
3. 任务3：种子数据脚本验证
4. 任务4：API 接口测试
5. 任务5：数据隔离验证
6. 任务6：Swagger 文档验证