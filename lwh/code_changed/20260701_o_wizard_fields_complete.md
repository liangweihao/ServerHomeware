# O：添加入库/编辑向导字段补全

## 技术开发文档

### 背景
4 步向导（`AddItemWizardView`）在 L 阶段对齐添加入库后，仍缺少旧 `ItemFormView` 中的购买与位置辅助字段，导致 `ItemFormController` 已支持的数据无法通过向导录入。

### 实现方案
1. **Step2 信息**：在品牌与物品图之间补充
   - 单价（`priceController`，两位小数）
   - 购买日期（`purchaseDate`，可清除）
   - 备注（`notesController`，最多 3 行）
2. **Step3 位置**：在位置选择后补充
   - 容器名称（`containerName`）
   - 位置参考照片（`locationImagePaths`）
3. 抽取 `ItemLocationPhotoSection` 复用位置参考照片 UI（拍照/相册、横滑缩略图、删除）

### 改动文件
| 文件 | 说明 |
|------|------|
| `widgets/add_item_wizard_view.dart` | 向导 Step2/Step3 字段 UI |
| `widgets/item_location_photo_section.dart` | 位置参考照片共用组件（新建） |

### 影响范围
- 添加入库（`add_item_page`）与编辑物品（`edit_item_page`）共用向导，字段双向生效
- API/本地落库逻辑不变，仍走 `ItemFormController.buildCreateApiBody` / `buildUpdateCompanion` / 草稿 `toDraftMap`
- `ItemFormView` 仍保留原实现，未强制迁移（后续可替换为共用组件）

## 提测开发文档

### 测试点
1. **添加入库 Step2**：填写单价、购买日期、备注 → 保存后详情/编辑页数据一致
2. **添加入库 Step3**：填写容器、添加 1～2 张位置参考照 → 保存后图片与容器名正确
3. **编辑模式**：打开已有物品，向导各步回显单价/购买日/备注/容器/位置照；修改后保存生效
4. **草稿恢复**：Step2/3 填一半退出再进入，草稿应含 price/notes/purchaseDate/locationImagePaths
5. **可选清空**：清除购买日期后提交，`purchase_date` 不应错误写入

### 验证方式
- 手动走 4 步向导完整流程
- 查看物品详情与再次进入编辑向导核对字段
- 抓包或日志确认 `purchase_price` / `purchase_date` / `notes` / `images`（含 `loc:` 前缀）提交

### 注意事项
- 单价仅允许数字与最多两位小数
- 位置参考照片最多 4 张（与组件默认一致）
- 编辑模式 Step2 仍展示「当前剩余量」提示，修改购买信息不改变剩余量
