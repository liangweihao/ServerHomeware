# B+ 供应商 + 毛利报表 + 批量导入 API

> 日期：2026-07-06  
> 范围：HomeWareServer + HomeWareClient（shop 空间）

---

## 技术开发文档

### 1. 供应商字段 `supplier`

**后端**
- 迁移 `0010_add_supplier_to_items.py`：`items.supplier VARCHAR(100) NULL`
- `Item` ORM / `CreateItemRequest` / `UpdateItemRequest` / `ItemResponse`
- `ItemService` 序列化、`allowed_fields`、CSV 导出列「供应商」

**客户端**
- Drift `items.supplier`，schema v6
- 表单/向导/详情（shop 专属）、同步与详情 Provider
- CSV 模板新增「供应商」列，Parser 别名 `供应商/供货商/supplier`

### 2. 毛利报表（扩展简易日销）

**模型**
- `DailySalesDay`：`cost`、`grossProfit`
- `ShopDailySalesSummary`：`totalCost`、`totalGrossProfit`、`costedSellQuantity`、`costIsComplete`
- `ItemSales7d`：同上字段

**计算**
- 基本单位进价 = `purchase_price / package_quantity`（`ShopDailySalesBuilder.unitCost`）
- 单行毛利 = `quantity × sale_price − quantity × unitCost`
- 无进价/售价时对应计 0，并标记「部分未设进价/售价」

**UI**
- `SpaceSkinConfig.dailySalesHeadline` / `formatItemSales7d` 展示毛利
- 首页 `ShopDailySalesCard`、统计页、物品详情「近7日卖出」

### 3. 服务端批量导入 API

**接口** `POST /api/v1/items/bulk`（注册在 `/{item_id}` 之前）
- 请求：`BulkCreateItemsRequest.items`（1～100 条 `CreateItemRequest`）
- 响应：`success_count`、`failed_count`、`items[{index, item}]`、`failures[{index, name, message}]`
- 部分失败不影响其余；逐条调用 `create_item`

**客户端**
- `ItemService.bulkCreateItems`
- `ShopCsvImportService`：优先 bulk（100 条/批），失败时整批回退逐条 `POST /items`

---

## 提测开发文档

### 测试点

| # | 场景 | 预期 |
|---|------|------|
| 1 | shop 空间新建/编辑物品填供应商 | 详情展示；刷新后仍在 |
| 2 | CSV 含供应商列导入 | 服务端与本地均有 supplier |
| 3 | 有进价+售价的商品记卖出 | 首页/统计页显示营业额与毛利 |
| 4 | 仅售价无进价 | 营业额正常，毛利提示「部分未设进价」 |
| 5 | CSV 一次导入 3～50 条 | 走 bulk API，成功数正确 |
| 6 | bulk 单条校验失败 | failures 含 index/原因，其余成功 |

### 验证方式

```bash
# 后端迁移
cd HomeWareServer
$env:PYTHONPATH="." ; alembic upgrade head

# 客户端单测
cd HomeWareClient
flutter test test/core/shop/
```

### 注意事项

- 家庭空间（home）不展示供应商/毛利 UI
- bulk 响应 `items` 元素含 `index` 字段，客户端据此对齐 CSV 行
- Drift 升级至 schema v6，老用户自动迁移 `supplier` 列

---

## 影响文件（主要）

- `HomeWareServer/app/api/v1/items.py`
- `HomeWareServer/app/services/item_service.py`
- `HomeWareServer/app/schemas/item.py`
- `HomeWareClient/lib/core/shop/shop_daily_sales_*.dart`
- `HomeWareClient/lib/core/shop/shop_csv_import_*.dart`
- `HomeWareClient/lib/core/services/item_service.dart`
- `HomeWareClient/lib/data/database/app_database.dart`
