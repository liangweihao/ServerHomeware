# B+ sale_price 售价字段

**日期**：2026-07-06  
**范围**：HomeWareServer + HomeWareClient  
**关联**：[current-phase.md](../../doc/product/current-phase.md) B+ 第一项

---

## 一、技术开发文档

### 实现方案

店铺空间支持商品 **售价**（`sale_price`），与现有 **进货单价**（`purchase_price`）并存：

| 层 | 改动 |
|----|------|
| DB | `items.sale_price` Numeric(10,2)，迁移 `0009_add_sale_price` |
| API | Create/Update/Detail/Export 透传 `sale_price` |
| 本地 Drift | `salePrice` 列，schema v5 |
| UI | shop 表单增「售价」；详情展示「进货单价 + 售价」 |
| 皮肤 | `SpaceSkinConfig` 增价格 label 与 `formatSalePrice` |

### 改动文件

**服务端**
- `alembic/versions/0009_add_sale_price.py`
- `app/models/item.py`
- `app/schemas/item.py`
- `app/services/item_service.py`
- `app/services/export_service.py`

**客户端**
- `lib/data/database/app_database.dart` + `.g.dart`
- `lib/core/config/space_skin_config.dart`
- `lib/presentation/items/item_form_controller.dart`
- `lib/presentation/items/item_form_view.dart`
- `lib/presentation/items/widgets/add_item_wizard_view.dart`
- `lib/presentation/items/item_detail_page.dart`
- `lib/core/providers/item_detail_provider.dart`
- `lib/core/services/item_sync_service.dart`
- `test/core/config/space_skin_config_test.dart`

### 影响范围

- **shop**：进货/售价双字段；home 仅保留购买价格，不展示售价行
- 需执行 `alembic upgrade head`（PostgreSQL/SQLite 开发库）
- 客户端自动迁移 schema v5

---

## 二、提测开发文档

### 测试点

1. **shop 进货**：向导/表单填写进货单价 + 售价 → 保存成功
2. **详情页**：shop 显示「进货单价」「售价 ¥x.xx/单位」
3. **home 回归**：详情仍只显示购买价格，无售价行
4. **API**：GET `/items/{id}` 返回 `sale_price`
5. **导出**：CSV 含「售价」列

### 验证命令

```powershell
# 服务端迁移
cd HomeWareServer
alembic upgrade head

# 客户端单测
cd HomeWareClient
flutter test test/core/config/space_skin_config_test.dart
```

### 注意事项

- 列表同步接口仍可能不返回 `purchase_price`/`sale_price`；详情拉取会纠正本地
- 日销统计（B+ 第 2 项）尚未实现，售价仅为展示与后续统计基础

---

## 三、下一步

- B+ 第 2 项：简易日销（基于 usage_records type=使用/卖出 × sale_price）
- 正式 Phase B Gate 店主外测
