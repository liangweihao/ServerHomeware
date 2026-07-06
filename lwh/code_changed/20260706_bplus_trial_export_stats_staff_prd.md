# B+ 外测体验增强：CSV 导出 + 统计页毛利图 + 店员角色 PRD

> 日期：2026-07-06  
> 范围：HomeWareClient + 产品文档

---

## 技术开发文档

### 1. 店铺 CSV 导出

- 新增 `ShopCsvExportService`：导出「使用中」商品，表头与 `ShopCsvImportTemplate` 完全一致
- 字段：商品名称、数量、单位、分类、位置、进货单价、售价、供应商、品牌、条码
- 入口：
  - CSV 批量进货页「导出库存 CSV」
  - 个人中心「数据导出」（shop 空间自动走进货模板格式）

### 2. 统计页毛利增强

- 近 7 日经营区增加 KPI 三栏：营业额 / 成本 / 毛利
- 有卖出数据时展示 **双柱图**（营业额 vs 毛利）+ 图例
- 无卖出时仍显示卖出次数柱图（原逻辑）

### 3. 店员角色 Epic PRD

- 文档：[`doc/product/phase-b-staff-role-prd.md`](../../doc/product/phase-b-staff-role-prd.md)
- 内容：角色映射（clerk）、权限矩阵、API/UI 守卫、里程碑 E1～E4、Go/No-Go

---

## 提测开发文档

| # | 场景 | 预期 |
|---|------|------|
| 1 | shop CSV 页点「导出库存 CSV」 | 生成 UTF-8 BOM 文件，Excel 可开 |
| 2 | 导出后在 Excel 改数量再导入 | 表头兼容，可回导 |
| 3 | 统计页有卖出记录 | 见 KPI + 双柱图 |
| 4 | home 空间个人中心导出 | 仍为原家庭 CSV 格式 |

### 验证

```bash
cd HomeWareClient
flutter test test/core/shop/
```

---

## 影响文件

- `lib/core/shop/shop_csv_export_service.dart`
- `lib/presentation/items/shop_csv_import_page.dart`
- `lib/presentation/statistics/statistics_page.dart`
- `lib/presentation/profile/widgets/export_data_dialog.dart`
- `doc/product/phase-b-staff-role-prd.md`
