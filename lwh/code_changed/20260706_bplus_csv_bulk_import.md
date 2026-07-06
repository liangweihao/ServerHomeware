# B+ CSV 批量进货

**日期**：2026-07-06  
**范围**：HomeWareClient  
**依赖**：B+ `sale_price`、店铺分类/位置 seed

---

## 一、技术开发文档

### 实现方案

| 模块 | 说明 |
|------|------|
| 解析 | `ShopCsvImportParser` — 表头别名 + 行校验 |
| 查找 | `ShopImportLookup` — 分类/位置名称 → 本地 ID，默认「其他」「店面」 |
| 导入 | `ShopCsvImportService` — 逐行 `POST /items` + 本地 Drift + 入库 usage |
| UI | `ShopCsvImportPage` — 选文件、预览、模板分享、进度 |
| 入口 | 录入方式页（shop 置顶）、个人中心物品快捷（shop） |

### CSV 模板列

`商品名称,数量,单位,分类,位置,进货单价,售价,品牌,条码`

- **必填**：商品名称  
- **默认**：数量 1、单位 件、分类「其他」、位置「店面」（可配置为本地首项）

### 新增依赖

- `file_picker` — 选择 CSV  
- `csv` — 解析/生成模板

### 改动文件

- `lib/core/shop/shop_csv_import_*.dart`、`shop_import_lookup.dart`
- `lib/presentation/items/shop_csv_import_page.dart`
- `lib/core/router/app_router.dart` — `/items/import/csv`
- `lib/presentation/items/add_item_method_page.dart`
- `lib/presentation/profile/widgets/profile_quick_actions_config.dart`
- `lib/core/config/space_skin_config.dart`
- `lib/data/database/app_database.dart` — `getAllCategoriesFlat`
- `test/core/shop/shop_csv_import_parser_test.dart`

### 影响范围

- shop 空间批量录入路径；home 仍可用 CSV 入库页（文案为「批量入库」）
- 无服务端批量 API；大量行时依赖网络逐条创建
- 未匹配分类/位置时回退默认值，不阻断导入

---

## 二、提测开发文档

### 测试点

1. 下载模板 → Excel/WPS 打开 → 填 2 行 → 另存 CSV UTF-8
2. 选择 CSV → 预览有效行数正确
3. 开始导入 → 物品列表出现新商品，含售价/位置
4. 错误行（空名称、数量 abc）在预览标红且跳过
5. home 账号：录入方式页无 CSV 卡片（个人中心仍可通过快捷项若开放 — 当前 shop 才显示快捷）

### 验证

```powershell
cd HomeWareClient
flutter test test/core/shop/shop_csv_import_parser_test.dart
```

手动：shop 账号 → 进货 → 录入方式 → CSV 批量进货。

### 注意事项

- Windows 选文件需 `file_picker` 权限正常
- 同名物品不会自动合并，仍走新增（与手动录入「仍然新增」一致）
- 大批量建议 ≤100 行/次，避免 API 限流

---

## 三、B+ 状态

- sale_price ✅  
- 简易日销 ✅  
- CSV 批量进货 ✅  

后续：毛利报表、供应商字段等为 B+ 扩展项。
