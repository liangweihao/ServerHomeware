# HomeStock Server — Phase 2：核心数据模型 & CRUD API

## 前置条件
Phase 1 已完成：项目骨架、数据库连接、用户认证系统就绪。

## 本阶段目标
创建所有业务数据模型，实现物品、分类、位置的完整 CRUD API。
完成后 Flutter 端可以通过 API 进行物品的增删改查。

---

## 任务1：业务数据模型

所有业务数据都归属于 family（家庭隔离），确保不同家庭的数据互不可见。

### Category 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | 所属家庭（系统预设的 family_id=null）|
| name | String(50) | |
| icon | String(20) | emoji |
| color | String(10) | hex颜色 |
| parent_id | Integer, FK → self, nullable | 父分类 |
| sort_order | Integer, default 0 | |
| is_system | Boolean, default False | 系统预设不可删 |
| is_active | Boolean, default True | 软删除 |
| created_at | DateTime | |

### Location 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | |
| name | String(50) | |
| icon | String(20), nullable | |
| parent_id | Integer, FK → self, nullable | |
| level | Integer | 1/2/3 |
| full_path | String(200) | 如"厨房/冰箱/冷藏层" |
| sort_order | Integer, default 0 | |
| is_active | Boolean, default True | |
| created_at | DateTime | |

### Item 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | |
| name | String(100) | |
| brand | String(50), nullable | |
| specification | String(100), nullable | |
| barcode | String(50), nullable | |
| category_id | Integer, FK → categories | |
| location_id | Integer, FK → locations, nullable | |
| purchase_price | Numeric(10,2), nullable | |
| total_price | Numeric(10,2), nullable | |
| purchase_quantity | Integer, default 1 | |
| current_quantity | Numeric(10,2), default 1 | |
| unit | String(10), default '件' | |
| safety_stock | Numeric(10,2), default 1 | |
| purchase_date | Date, nullable | |
| purchase_channel | String(50), nullable | |
| production_date | Date, nullable | |
| expiry_date | Date, nullable | |
| shelf_life_days | Integer, nullable | |
| opened_date | Date, nullable | |
| after_open_days | Integer, nullable | |
| warranty_date | Date, nullable | |
| expiry_alert_days | Integer, default 3 | |
| stock_alert | Boolean, default True | |
| notes | Text, nullable | |
| status | Integer, default 0 | 0使用中/1用完/2过期/3丢弃 |
| avg_daily_consumption | Numeric(10,4), nullable | |
| predicted_empty_date | Date, nullable | |
| created_by | Integer, FK → users | 创建人 |
| created_at | DateTime | |
| updated_at | DateTime | |

### ItemImage 模型（物品图片，独立表）
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| item_id | Integer, FK → items | |
| url | String(500) | 图片路径/URL |
| sort_order | Integer, default 0 | |
| created_at | DateTime | |

### UsageRecord 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| item_id | Integer, FK → items | |
| family_id | Integer, FK → families | |
| type | Integer | 0入库/1使用/2丢弃/3移动/4调整 |
| quantity | Numeric(10,2) | 变更数量 |
| remaining_quantity | Numeric(10,2) | 变更后剩余 |
| operator_id | Integer, FK → users, nullable | 操作人 |
| operator_name | String(50), nullable | 操作人名称冗余 |
| from_location_id | Integer, nullable | 移动前位置 |
| to_location_id | Integer, nullable | 移动后位置 |
| notes | String(200), nullable | |
| created_at | DateTime | |

### ShoppingItem 模型
| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer, PK | |
| family_id | Integer, FK → families | |
| name | String(100) | |
| related_item_id | Integer, FK → items, nullable | |
| quantity | Numeric(10,2), default 1 | |
| unit | String(10), default '件' | |
| estimated_price | Numeric(10,2), nullable | |
| is_purchased | Boolean, default False | |
| is_auto_generated | Boolean, default False | |
| priority | Integer, default 0 | |
| purchased_at | DateTime, nullable | |
| purchased_by | Integer, FK → users, nullable | |
| created_at | DateTime | |

---

## 任务2：Alembic 迁移

生成迁移脚本创建以上所有表。
为常用查询添加索引：
- items: family_id, status, category_id, location_id, expiry_date, barcode
- usage_records: item_id, family_id, created_at
- shopping_items: family_id, is_purchased
- locations: family_id, parent_id
- categories: family_id, parent_id

---

## 任务3：通用 Repository 基类

创建 BaseRepository 类，提供通用 CRUD 方法：
- get_by_id(id) → 单条查询
- get_list(filters, page, page_size, order_by) → 分页查询
- create(data) → 新增
- update(id, data) → 更新
- delete(id) → 删除（软删除 is_active=False）
- hard_delete(id) → 物理删除

所有方法自动加上 family_id 过滤（数据隔离）。

---

## 任务4：分类 API

### 接口清单

**GET /api/v1/categories**
```
说明：获取当前家庭的所有分类（树形结构）
响应：包含父分类及其子分类的嵌套列表
逻辑：查询 family_id=当前家庭 OR is_system=True 的分类
按 parent_id 组装成树形
```

**POST /api/v1/categories**
```
说明：创建自定义分类
请求：{name, icon, color, parent_id(可选)}
逻辑：family_id=当前家庭，is_system=False
```

**PUT /api/v1/categories/{id}**
```
说明：更新分类（仅可改自定义分类）
请求：{name, icon, color, sort_order}
逻辑：检查 is_system=False 才允许修改
```

**DELETE /api/v1/categories/{id}**
```
说明：删除分类
逻辑：is_system=True 不可删；检查该分类下是否有物品，有则拒绝删除
```

---

## 任务5：位置 API

### 接口清单

**GET /api/v1/locations**
```
说明：获取当前家庭所有位置（树形结构）
查询参数：parent_id（可选，获取某层级下的子位置）
响应：树形结构，每个位置附带 item_count（该位置下的物品数量）
```

**GET /api/v1/locations/{id}**
```
说明：获取位置详情
响应：位置信息 + 子位置列表 + 该位置下的物品列表
```

**POST /api/v1/locations**
```
请求：{name, icon, parent_id(可选)}
逻辑：
- 自动计算 level（无parent=1，有parent=parent.level+1，最大3）
- 自动拼接 full_path
- family_id=当前家庭
```

**PUT /api/v1/locations/{id}**
```
请求：{name, icon, sort_order}
逻辑：更新后如果name变了，更新 full_path 和所有子位置的 full_path
```

**DELETE /api/v1/locations/{id}**
```
逻辑：检查该位置及子位置下是否有物品，有则拒绝（返回400+提示信息）
无物品则删除该位置及所有子位置
```

---

## 任务6：物品 CRUD API

### 接口清单

**GET /api/v1/items**
```
说明：获取物品列表（分页 + 筛选 + 排序）
查询参数：
- page, page_size（分页）
- status: 0/1/2/3（状态筛选）
- category_id（分类筛选）
- location_id（位置筛选）
- keyword（搜索名称/品牌）
- sort_by: expiry_date/created_at/current_quantity/purchase_price
- sort_order: asc/desc
- expiring_within_days: 7（即将过期筛选，过期日期在N天内）
- low_stock: true（库存低于safety_stock的）
响应：分页列表，每个物品附带 category_name, location_full_path, urgency, preview_image(首张缩略图URL) 字段
```

**GET /api/v1/items/{id}**
```
说明：获取物品详情
响应：完整物品信息 + 图片列表 + 最近5条使用记录
```

**POST /api/v1/items**
```
请求：全量字段（name和category_id必填，其余可选）
逻辑：
- 如果没传 current_quantity，默认等于 purchase_quantity
- 如果传了 production_date + shelf_life_days 但没传 expiry_date，自动计算
- 如果传了 purchase_price + purchase_quantity，自动计算 total_price
- created_by = 当前用户
- 同时插入一条 usage_record（type=0入库，quantity=purchase_quantity）
- family_id=当前家庭
```

**PUT /api/v1/items/{id}**
```
请求：部分更新（只传需要改的字段）
逻辑：更新 updated_at，如果改了 expiry_date 要重新调度提醒
```

**DELETE /api/v1/items/{id}**
```
逻辑：物理删除物品及其关联数据
同时删除关联的 usage_records 和 item_images 数据库记录
同时删除磁盘上的图片文件（uploads/{family_id}/ 目录下）
从 shopping_list 中解除关联
```

**POST /api/v1/items/{id}/use**
```
说明：快捷记录使用
请求：{quantity, operator_name(可选)}
逻辑：
- 更新 current_quantity -= quantity
- 插入 usage_record（type=1使用）
- 如果 current_quantity <= 0，自动更新 status=1（已用完）
- 更新 avg_daily_consumption 和 predicted_empty_date
- 返回更新后的物品信息
```

**POST /api/v1/items/{id}/finish**
```
说明：标记用完
逻辑：current_quantity=0, status=1, 记录usage_record
```

**POST /api/v1/items/{id}/discard**
```
说明：标记丢弃
逻辑：status=3, 记录usage_record(type=2)
```

**POST /api/v1/items/{id}/move**
```
说明：移动位置
请求：{to_location_id}
逻辑：更新 location_id，记录 usage_record(type=3，含from和to)
```

**GET /api/v1/items/barcode/{barcode}**
```
说明：根据条码查询物品（检查当前家庭是否已有该条码物品）
响应：物品信息 或 404
```

---

### 使用记录 API

**GET /api/v1/usage_records**
```
说明：获取使用记录（不传 item_id=全家庭分页，传 item_id=单物品全部记录）
参数：item_id(可选), page(默认1), page_size(默认20, 最大100)
响应：分页列表，每条含 item_name, type(0入库/1使用/2丢弃/3移动/4调整), quantity, remaining_quantity, operator_name, created_at
```

**POST /api/v1/usage_records**
```
请求：{item_id, used_quantity, notes(可选)}
逻辑：创建使用记录，used_by=当前用户
```

**DELETE /api/v1/usage_records/{record_id}**
```
说明：删除指定使用记录
```

---

## 任务7：预设数据种子脚本

创建 scripts/seed_data.py：
- 插入系统预设分类（family_id=null, is_system=True）
- 首次创建家庭时，自动从预设模板复制位置结构到该家庭

预设分类数据：
```
食品饮料🍎 #FF8A65：乳制品、肉类、蔬果、零食、饮品、调味品、粮油、速食
日用清洁🧹 #4DB6AC：洗衣、厨房清洁、纸巾、垃圾袋
个护美妆🧴 #F06292：洗护、口腔、护肤、彩妆
药品保健💊 #7986CB：常用药、保健品、医疗器械
家用电器📺 #FFD54F：大家电、小家电、数码
衣物鞋帽👕 #F06292
其他📦 #A1887F
```

预设位置模板（用户注册创建家庭时复制）：
```
厨房🍳：冰箱(冷藏层/冷冻层/门侧)、吊柜(一层/二层/三层)、调料架、水槽下方、台面
卫生间🛁：洗漱台(台面/镜柜/下方)、浴室柜、马桶旁
客厅🛋️：电视柜、茶几(上方/下方)、书架
主卧🛏️：衣柜(上层/中层/下层/抽屉)、床头柜(台面/抽屉)、梳妆台
次卧🛏️：衣柜、书桌
阳台☀️：储物柜(上层/下层)、晾衣区
```

---

## 验收标准

1. ✅ 数据库迁移成功，所有表已创建
2. ✅ 分类API：获取树形分类列表、创建/编辑/删除自定义分类
3. ✅ 位置API：树形结构获取、创建/删除带保护检查
4. ✅ 物品API：完整CRUD、分页查询、多条件筛选、排序
5. ✅ 物品使用：/use接口正确更新数量和记录
6. ✅ 标记用完/丢弃正确更新状态
7. ✅ 所有接口有 family_id 数据隔离
8. ✅ Swagger 文档清晰可读
9. ✅ 预设数据脚本可正确执行
10. ✅ 注册新用户时自动创建家庭+位置模板