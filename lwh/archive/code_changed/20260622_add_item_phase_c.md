# 录入页 Phase C — 首屏 + 折叠改版

**日期**：2026-06-22  
**规格**：`doc/design/add-item-redesign.md`

## 实现方案

1. **首屏最小闭环**：名称、分类 Chip、数量/单位、位置一行、紧凑照片入口
2. **手风琴折叠**：expiry / stock / purchase / locationDetail / more，同时最多展开 1 块
3. **分类联动**：`CategoryFormPolicy` 负责主折叠、排序、默认 `expiry_alert_days` / `safety_stock`
4. **包装轻量露出**：单位 ∈ 盒/箱/提/板/袋/包/瓶 时首屏显示「每 X 含 n 个」
5. **最近分类**：SharedPreferences 存最近 3 个 categoryId

## 改动文件

| 文件 | 说明 |
|------|------|
| `category_form_policy.dart` | 新增：折叠策略与摘要 |
| `category_recent_storage.dart` | 新增：最近分类本地存储 |
| `item_form_view.dart` | 重写：首屏 + 手风琴 |
| `item_form_controller.dart` | displayUnit 联动、buildCreateApiBody 修复 |
| `widgets/item_form_category_chips.dart` | 新增：7 常用 + 最近 + 全部分类 |
| `widgets/item_image_picker_section.dart` | compact 模式 + sheet 管理 |
| `add_item_page.dart` | 灰底、保存并继续重置折叠 |
| `edit_item_page.dart` | 灰底、isEditMode 复用新表单 |

## 提测要点

1. **添加流程**：名称 + 分类必填；保存入库 / 保存并继续均正常
2. **分类 Chip**：点 7 常用一级、最近使用、全部分类树；选中描边 primary
3. **切换分类**：自动展开对应主折叠（食品→保质期，日用→库存，电器→购买，家居→存放详情）
4. **包装**：单位选「盒」→ 出现每盒含；总量提示正确；保存后 API `package_unit` / `package_quantity` 正确
5. **照片**：首屏「+ 添加照片」；已有图显示「已 n 张」并可 sheet 管理
6. **编辑页**：预填数据、购买折叠剩余量提示、折叠默认收起
7. **位置**：首屏「放在哪？」；容器/位置照在「存放详情」折叠

## 注意事项

- 扫码入库自动展开 expiry（§七）尚未接入路由参数，可后续迭代
- 校验逻辑未变：仅名称 + 分类必填
