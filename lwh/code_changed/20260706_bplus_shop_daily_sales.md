# B+ 简易日销（近7日卖出统计）

**日期**：2026-07-06  
**范围**：HomeWareClient（本地 usage_records 聚合）  
**依赖**：B+ `sale_price` 字段

---

## 一、技术开发文档

### 实现方案

基于本地 Drift `usage_records`（type=1 消耗/卖出）聚合近 **7 个自然日**：

| 指标 | 说明 |
|------|------|
| 卖出次数 | type=1 记录条数 |
| 售出数量 | quantity 合计 |
| 营业额 | Σ(quantity × item.sale_price)，无售价计 0 |

### 展示位置（仅 shop）

| 位置 | 内容 |
|------|------|
| 首页 | `ShopDailySalesCard` — 汇总 + 7 日迷你柱图 |
| 数据统计 | 顶部「近7日经营」柱状图 |
| 物品详情 | 「近7日卖出」行 + 使用记录文案「卖出」 |

### 新增文件

- `lib/core/shop/shop_daily_sales_models.dart`
- `lib/core/shop/shop_daily_sales_builder.dart`
- `lib/core/providers/shop_daily_sales_provider.dart`
- `lib/presentation/home/widgets/shop_daily_sales_card.dart`
- `test/core/shop/shop_daily_sales_builder_test.dart`

### 改动文件

- `lib/data/database/app_database.dart` — `getUsageRecordsSince` / `getUsageRecordsByItemSince`
- `lib/core/config/space_skin_config.dart` — 日销文案
- `lib/presentation/home/home_page.dart`
- `lib/presentation/statistics/statistics_page.dart`
- `lib/presentation/items/item_detail_page.dart`

### 影响范围

- home 空间无 UI 变化
- 未设售价的商品仍计卖出次数，营业额可能不完整（有提示文案）
- 纯客户端统计，服务端暂无日销 API

---

## 二、提测开发文档

### 测试点

1. shop 账号：记几笔「卖出」→ 首页卡片次数增加
2. 设售价 3.5，卖出 2 瓶 → 营业额含 ¥7.00
3. 物品详情「近7日卖出」与首页一致
4. 数据统计页顶部柱状图有 7 日分布
5. home 账号：无日销卡片、统计页无店铺区块

### 验证

```powershell
cd HomeWareClient
flutter test test/core/shop/shop_daily_sales_builder_test.dart
flutter test test/core/config/space_skin_config_test.dart
```

### 注意事项

- 仅统计本地库 usage 记录；多端需 usage 同步完整后才准确
- 毛利/进价差报表仍为 B+ 后续项

---

## 三、下一步

- B+ CSV 批量进货
- 可选：服务端日销 API / 跨设备一致
