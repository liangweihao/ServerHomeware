# HomeStock — Phase 2：核心 CRUD

## 前置条件
Phase 1 已完成：项目骨架、设计系统、数据库、路由、底部导航均已就绪。

## 本阶段目标
实现物品管理的核心流程：录入物品 → 查看列表 → 查看详情 → 记录使用/消耗。
完成后用户可以完整地添加物品、浏览物品、记录使用。

---

## 任务1：通用组件库

在 presentation/common/widgets/ 下创建以下可复用组件：

### AppButton
- 属性：label, onPressed, variant(primary/secondary/outline/ghost/danger), size(large48/medium40/small32), leadingIcon, trailingIcon, isLoading, isFullWidth
- primary: 主色底白字；secondary: 浅主色底主色字；outline: 白底灰边框；ghost: 透明底主色字；danger: 红底白字
- isLoading 时显示 CircularProgressIndicator 替代文字

### AppTag
- 属性：label, variant(default/success/warning/danger/info), size(medium/small)
- 药丸形圆角，各variant对应不同背景色和文字色

### AppProgressBar
- 属性：value(0-1), height(默认4), colorMode(auto/fixed)
- auto模式：0-0.3红色，0.3-0.6橙色，0.6-1绿色（表示剩余量越多越安全）
- 圆角两端

### QuantityStepper
- 属性：value, min, max, step, unit(可选), onChanged
- 横向排列：[-] [数值] [+]，到达min/max时按钮灰显禁用

### AppEmptyState
- 属性：icon(emoji字符串), title, subtitle, actionLabel(可选), onAction(可选)
- 居中显示：大emoji + 标题 + 描述 + 可选按钮

### AppSearchBar
- 属性：placeholder, onTap, onChanged, readOnly
- 药丸形、灰色背景、左侧搜索图标
- readOnly模式点击时触发onTap（用于跳转搜索页）

---

## 任务2：物品录入页（AddItemPage）

路由：/items/add

### 顶部
AppBar 标题"添加物品"，左侧返回，右侧"保存"文字按钮

### 录入方式弹窗（AddMethodSheet）
中间Tab的"+"按钮点击后弹出底部弹窗，列出：
- 扫码录入（图标+文字，点击跳转/items/scan）
- 手动录入（点击跳转/items/add）

Phase2只实现手动录入，扫码留到Phase5。

### 表单设计
使用 Form + 分区（每个区块有标题），可滚动。

**物品照片区（可选）：**
- 横向滚动缩略图列表，最多 5 张
- 「+ 添加」→ 底部弹窗选择「相册 / 拍照」（image_picker）
- 图片复制到应用目录，路径 JSON 数组写入 `items.images` 字段
- 缩略图右上角 × 删除本地文件

**基本信息区：**
- 物品名称*（TextFormField，必填校验）
- 分类*（点击弹出底部弹窗，显示所有分类grid，选择后显示所选分类名）
- 品牌（可选输入框）

**购买信息区：**
- 数量（QuantityStepper）+ 单位（下拉选择，选项用预设单位列表）
- 单价（数字输入框，前缀¥）
- 购买日期（日期选择器）
- 购买渠道（下拉：京东/淘宝/拼多多/超市/便利店/其他）

**时效信息区：**
- 生产日期（日期选择器）
- 保质期（下拉：7天/14天/1个月/3个月/6个月/1年/2年/3年）
- 到期日期（日期选择器，若已选生产日期+保质期则自动计算并填入，也可手动改）

**存放位置区：**
- LocationPicker 组件（点击弹出三级级联选择底部弹窗）

**提醒设置区：**
- 过期提前提醒（下拉：1天/3天/7天/14天/30天）
- 库存预警数量（QuantityStepper）

**备注区：**
- 多行输入框

### 底部固定
- 「保存入库」按钮（Primary, 全宽）
- 「保存并继续添加」（Ghost按钮）

### 保存逻辑
1. 校验必填项（名称、分类）
2. 构造 Item 实体，current_quantity = purchase_quantity
3. 写入数据库
4. 同时写入一条 usage_record（type=0入库）
5. 显示成功 SnackBar
6. 「保存入库」→ 返回上一页
7. 「保存并继续添加」→ 清空表单（保留分类和位置选择），继续录入

### LocationPicker 组件
点击触发底部弹窗（高度60%屏幕）：
- 顶部拖拽条 + 标题"选择位置" + 关闭按钮
- 中间三列级联：第一列房间，第二列区域，第三列具体位置
- 选中项高亮主色
- 底部显示当前选择路径 + 确认按钮

### CategorySelector 组件
点击触发底部弹窗：
- 显示所有一级分类，Grid布局（每行4个），每个是 emoji + 名称
- 选中后如有子分类，展示第二层
- 选中后关闭弹窗，回填

---

## 任务3：物品列表页（ItemListPage）

路由：/items（底部Tab第二个）

### 结构
- AppBar 标题"所有物品"，右侧搜索图标 + 筛选图标
- 顶部分类Tab横向滚动（全部 + 各一级分类），选中有下划线指示
- 排序信息行：左"共X件"，右"排序：xxx ▼"
- 物品列表（ListView）

### ItemCard 组件
横向布局卡片：
- 最左侧：3px宽的状态色条（根据紧急程度：绿/橙/红/灰）
- 缩略图：56x56，有图显示图片，无图显示分类emoji
- 内容区：
  - 第一行：名称（加粗）+ 右侧状态Tag（即将过期/库存低/已过期）
  - 第二行：📍位置图标 + 位置路径文字（灰色小字）
  - 第三行：剩余数量 + 过期倒计时
  - 第四行：AppProgressBar 显示使用进度
- 右侧：快捷「使用」按钮（减号圆形图标）

卡片背景白色、圆角12、轻微阴影。

紧急程度判断逻辑：
- 已过期(expiry_date < today) → 灰色 + "已过期"标签
- ≤3天过期 → 红色 + "即将过期"
- ≤7天过期 → 橙色 + "注意"
- 库存 ≤ safety_stock → 橙色 + "库存低"
- 其他 → 绿色，无标签

### 使用左滑（flutter_slidable）
左滑露出三个按钮：
- 使用（绿色）→ 弹出使用Dialog
- 编辑（蓝色）→ 跳转编辑页
- 删除（红色）→ 确认弹窗后删除

### 筛选底部弹窗
点击筛选图标弹出：
- 状态筛选：全部/使用中/即将过期/已过期/已用完（横向可选Tag）
- 位置筛选：全部 + 各房间（横向可选Tag）
- 分类筛选：全部 + 各分类（横向可选Tag）
- 排序选择：单选列表（过期时间近→远 / 录入时间新→旧 / 剩余数量少→多 / 价格高→低）
- 底部确认按钮

### 数据查询
- 根据当前选中的分类Tab、筛选条件、排序方式从数据库查询
- 列表为空时显示 AppEmptyState

---

## 任务4：物品详情页（ItemDetailPage）

路由：/items/:id

### AppBar
左侧返回，右侧编辑图标 + 更多菜单（移动位置/删除）

### 内容（可滚动）

**图片区域：** 如有图片显示轮播，无图显示大号分类emoji（背景灰色区域，高度200）

**标题区：** 物品名称(H3) + 分类Tag + 品牌文字

**三指标行：** 三等分显示
- 剩余数量（数值 + 单位，根据是否低库存变色）
- 过期倒计时（X天 或 "无限制"，根据紧急程度变色）
- 消耗速率（X单位/周 或 "暂无数据"）

**进度条区域：**
- AppProgressBar（使用量/购买量）
- 下方文字："预计用完时间：xxxx-xx-xx（约X天后）"

**详细信息区域：** 列表形式
- 📍 存放位置 → 位置路径
- 💰 购买价格 → ¥xx × 数量 = ¥总价
- 🛒 购买渠道 → 渠道名
- 📅 购买日期
- 📅 生产日期
- ⏰ 到期日期
- 🔔 提醒设置

**使用记录区域：**
- 标题"使用记录"
- 时间线样式列表（竖线连接圆点）：日期时间 + 操作描述 + 剩余量 + 操作人
- 最多显示5条 + "查看全部"按钮

### 底部固定操作栏
三个按钮一行排列：
- 「使用1件」secondary
- 「已用完」outline
- 「再次购买」primary

---

## 任务5：使用/消耗记录功能

### UsageDialog 弹窗
点击「使用1件」或列表快捷按钮时弹出 Dialog：
- 标题：记录使用
- 物品名称显示
- 当前剩余显示
- 本次使用数量：QuantityStepper（默认1，max=当前剩余）
- 操作人选择：从 family_members 读取，横排展示，可选
- 使用后剩余显示（实时计算）
- 如果使用后剩余 ≤ safety_stock，显示⚠️提示文字
- 两个按钮："确认使用" + "全部用完"

### 确认使用逻辑
1. 更新 items 表：current_quantity -= 使用数量，updated_at = now
2. 插入 usage_records：type=1(使用), quantity=使用量, remaining=新剩余
3. 如果新剩余 = 0，自动将 status 改为 1(已用完)
4. 关闭弹窗，刷新页面数据
5. 显示 SnackBar "已记录使用X件，剩余X件"

### 「已用完」逻辑
直接将 current_quantity 设为 0，status 设为 1，记录一条 usage_record。

### 「再次购买」逻辑
将该物品添加到 shopping_list 表（name=物品名，related_item_id=物品ID，quantity=purchase_quantity，unit=物品unit，estimated_price=purchase_price）
显示 SnackBar "已加入购物清单"

---

## 任务6：编辑物品页（EditItemPage）

路由：/items/:id/edit

### 入口
- 物品详情 AppBar「编辑」→ `/items/:id/edit`
- 物品列表左滑「编辑」（如有）

### 与添加页差异
| 项目 | 添加页 | 编辑页 |
|------|--------|--------|
| 标题 | 添加物品 | 编辑物品 |
| 预填 | 空表单 | 从本地 DB 读取并预填（含图片） |
| 底部按钮 | 保存入库 + 保存并继续 | 仅「保存修改」 |
| 保存逻辑 | POST 创建 + 本地 insert + 入库记录 | PUT 更新（失败仍写本地）+ `updateItem` |
| 数量说明 | 数量=购买量=初始剩余 | 显示当前剩余只读；购买数量可改 |

### 表单结构
与 `AddItemPage` 共用 `ItemFormView` + `ItemFormController`（含照片区、各分区字段）。

### 保存逻辑
1. 校验名称、分类
2. 调用 `PUT /api/v1/items/{id}`（图片暂仅存本地 JSON）
3. `db.updateItem` 写回本地（保留 `current_quantity`、`status` 等）
4. 失效 `itemDetailProvider` / 列表 Provider
5. SnackBar「保存成功」并返回详情/列表

### 交互流程
```
详情/列表 → 编辑页（loading）
  → 成功：展示预填表单
  → 失败：空态「物品不存在」
用户修改字段 / 增删照片 → 点保存
  → 成功：返回上一页，详情数据刷新
  → 失败：SnackBar 错误信息
```

---

## 验收标准

1. ✅ 可以通过手动表单完整录入一个物品（含分类选择、位置选择）
2. ✅ 物品列表正确显示所有物品，分类Tab筛选有效
3. ✅ 筛选弹窗可按状态/位置/分类筛选，排序有效
4. ✅ 物品卡片正确显示状态颜色、进度条、紧急标签
5. ✅ 物品详情页显示完整信息
6. ✅ 记录使用后数量正确更新，usage_records 有记录
7. ✅ 「已用完」正确更新状态
8. ✅ 「再次购买」正确添加到购物清单
9. ✅ 左滑删除有确认弹窗，删除后列表刷新
10. ✅ 编辑物品可正确回填和保存