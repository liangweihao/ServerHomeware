# L 阶段：编辑页对齐添加入库向导

## 技术开发文档

### 背景

`edit_item_page` 仍使用长表单 `ItemFormView`，与 `add_item_page` 的 4 步向导（分类→信息→位置→时效）体验不一致。

### 实现方案

1. **`AddItemWizardView`** 增加 `isEditMode`：
   - 分类步：隐藏扫码按钮，文案改为「确认或修改分类」
   - 信息步：展示「当前剩余」只读提示；数量标签改为「购买数量」
   - 时效步：编辑模式下展示「安全库存」步进器

2. **`edit_item_page.dart`** 重写：
   - 复用 `AddItemWizardView` + 与添加入库相同的步骤校验与底部「上一步 / 下一步 / 保存修改」
   - 加载态/空态仍用 `WarmScaffold`
   - 保存后 `invalidate(homeSectionsProvider)` 刷新首页分区

3. **`item_form_controller.loadFromItem`** 补充 `barcode` 预填，编辑时显示条码 Chip

### 改动文件

| 文件 | 说明 |
|------|------|
| `edit_item_page.dart` | 4 步向导编辑页 |
| `add_item_wizard_view.dart` | `isEditMode` 分支 UI |
| `item_form_controller.dart` | 编辑预填 barcode |

### 影响范围

- 物品详情 → 编辑
- 路由 `/items/:id/edit`

---

## 提测开发文档

### 测试点

1. 详情页点「编辑」→ 4 步指示器与添加入库一致
2. 各步预填：分类、名称、数量、位置、过期日、安全库存
3. 信息步显示「当前剩余 X 件」提示
4. 修改名称/位置/过期日后保存 → 详情与首页分区更新
5. 分类步无「扫码录入」按钮（编辑专用）
6. 必填校验：无分类/无名称时 SnackBar 并跳转对应步

### 验证方式

打开已有物品 → 编辑 → 逐步修改 → 保存 → 返回详情与首页核对。

### 注意事项

- 编辑购买数量不会自动改 `currentQuantity`（与旧版 ItemFormView 行为一致）
- 未迁移 ItemFormView 中的单价/购买日期等高级字段到向导；后续可按需在「信息/时效」步扩展
