# HomeStock Server Phase 2 实现计划

## 一、项目现状分析

### 1.1 现有代码结构
```
HomeWareServer/
├── app/
│   ├── api/v1/
│   │   ├── categories.py      # 分类API（已实现）
│   │   ├── locations.py       # 位置API（已实现）
│   │   ├── items.py           # 物品API（基础实现）
│   │   └── ...
│   ├── models/
│   │   ├── category.py        # 分类模型（已实现）
│   │   ├── location.py        # 位置模型（已实现）
│   │   ├── item.py            # 物品模型（已实现）
│   │   ├── usage_record.py    # 使用记录模型（已实现）
│   │   └── shopping.py        # 购物清单模型（已实现）
│   ├── services/
│   │   ├── category_service.py    # 分类服务（已实现）
│   │   ├── location_service.py    # 位置服务（已实现）
│   │   └── item_service.py        # 物品服务（已实现）
│   └── repositories/
│       ├── base.py                # 基础仓库（已实现）
│       └── ...
├── alembic/
│   └── versions/
│       └── 0001_initial_migration.py  # 初始迁移（需要更新）
└── scripts/
    └── seed_data.py            # 种子数据脚本（已实现）
```

### 1.2 问题识别

| 问题 | 位置 | 描述 |
|------|------|------|
| 迁移脚本过时 | `alembic/versions/0001_initial_migration.py` | 表结构与当前模型不匹配，缺少字段和索引 |
| 物品API功能不全 | `app/api/v1/items.py` | 缺少分页、筛选、使用记录等功能 |
| Schema 过时 | `app/schemas/item.py` | 字段与当前模型不匹配 |
| 索引缺失 | 数据库 | 需要为常用查询添加索引 |

---

## 二、实现任务清单

### 任务1：更新数据迁移脚本（Alembic）

**目标**：创建新的迁移脚本，包含完整的表结构和索引

**步骤**：
1. 检查当前模型与迁移脚本的差异
2. 创建新的迁移脚本 `0002_add_business_tables.py`
3. 为以下表添加索引：
   - `items`: family_id, status, category_id, location_id, expiry_date, barcode
   - `usage_records`: item_id, family_id, created_at
   - `shopping_items`: family_id, is_purchased
   - `locations`: family_id, parent_id
   - `categories`: family_id, parent_id

**文件修改**：
- 创建 `alembic/versions/0002_add_business_tables.py`

---

### 任务2：更新物品 API

**目标**：完善物品CRUD接口，支持分页、筛选、排序

**步骤**：
1. 更新 `GET /api/v1/items` 接口：
   - 添加分页参数（page, page_size）
   - 添加筛选参数（status, category_id, location_id, keyword）
   - 添加排序参数（sort_by, sort_order）
   - 添加特殊筛选（expiring_within_days, low_stock）
2. 更新 `GET /api/v1/items/{id}` 接口：返回完整信息+图片+使用记录
3. 添加 `POST /api/v1/items/{id}/use` 接口：记录使用
4. 添加 `POST /api/v1/items/{id}/finish` 接口：标记用完
5. 添加 `POST /api/v1/items/{id}/discard` 接口：标记丢弃
6. 添加 `POST /api/v1/items/{id}/move` 接口：移动位置
7. 添加 `GET /api/v1/items/barcode/{barcode}` 接口：条码查询

**文件修改**：
- `app/api/v1/items.py`

---

### 任务3：更新 Schema 定义

**目标**：更新请求/响应模型以匹配当前数据模型

**步骤**：
1. 更新 `ItemResponse`：添加新字段（brand, specification, barcode, current_quantity等）
2. 更新 `CreateItemRequest`：添加完整字段
3. 更新 `UpdateItemRequest`：添加完整字段
4. 添加 `UseItemRequest`：使用物品请求模型

**文件修改**：
- `app/schemas/item.py`

---

### 任务4：完善种子数据脚本

**目标**：确保种子脚本能够正确初始化系统预设分类

**步骤**：
1. 修复 `seed_data.py` 中的parent_id处理逻辑
2. 确保系统分类的family_id为null
3. 添加创建家庭时自动复制位置模板的逻辑

**文件修改**：
- `scripts/seed_data.py`
- `app/services/family_service.py`（添加位置模板复制逻辑）

---

### 任务5：验证构建和启动

**目标**：确保所有代码正确运行

**步骤**：
1. 运行数据库迁移
2. 执行种子数据脚本
3. 启动开发服务器
4. 验证API接口

---

## 三、风险与注意事项

### 3.1 数据模型兼容性
- 当前数据库中的表结构与模型定义不一致，需要通过迁移脚本同步
- 建议先备份数据再执行迁移

### 3.2 索引性能
- 添加索引会提高查询性能，但会降低写入性能
- 需要根据业务需求权衡

### 3.3 数据隔离
- 所有API必须确保family_id数据隔离
- 系统预设分类（family_id=null）对所有家庭可见

### 3.4 代码规范
- 所有新增代码必须添加注释/注解
- 核心业务代码必须添加日志
- 代码变更记录保存到 `lwh/code_changed` 目录

---

## 四、验收标准

| 序号 | 验收项 | 验证方式 |
|------|--------|----------|
| 1 | 数据库迁移成功 | 执行 `alembic upgrade head` |
| 2 | 分类API：树形列表、CRUD | 测试各接口 |
| 3 | 位置API：树形结构、创建/删除保护 | 测试各接口 |
| 4 | 物品API：分页、筛选、排序 | 测试各接口 |
| 5 | 物品使用接口：/use、/finish、/discard、/move | 测试各接口 |
| 6 | 条码查询接口 | 测试 `GET /api/v1/items/barcode/{barcode}` |
| 7 | 数据隔离验证 | 使用不同家庭用户访问数据 |
| 8 | Swagger文档 | 访问 `/docs` |
| 9 | 预设数据脚本 | 执行 `python scripts/seed_data.py` |
| 10 | 新用户注册自动创建位置模板 | 注册新用户验证 |

---

## 五、任务时间估算

| 任务 | 预估时间 |
|------|----------|
| 任务1：迁移脚本 | 2小时 |
| 任务2：物品API | 3小时 |
| 任务3：Schema更新 | 1小时 |
| 任务4：种子数据 | 1小时 |
| 任务5：验证测试 | 2小时 |
| **总计** | **9小时** |