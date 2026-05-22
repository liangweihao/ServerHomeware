# 分阶段 Trae 提示词

***

## 📋 Phase 1：基础骨架

```markdown
# HomeStock 家庭物品管理 App — Phase 1：基础骨架

## 项目背景
开发一个 Flutter App，帮助用户管理家庭物品的全生命周期。
核心功能：知道家里有什么、在哪里、还能用多久、什么时候该买。
目标平台：iOS + Android，语言：中文。

## 技术选型
- Flutter 3.x + Dart
- 状态管理：Riverpod 2.x（code generation 模式）
- 本地数据库：Drift（SQLite）
- 路由：GoRouter
- 数据类：Freezed
- UI风格：Material 3
- 架构：Clean Architecture（data / domain / presentation 三层）

## 本阶段目标
搭建完整的项目骨架，包括：项目结构、设计系统、数据库、路由、底部导航。
完成后 App 可以运行，能看到底部导航切换空白页面。

---

## 任务1：项目初始化 & 目录结构

创建 Flutter 项目，名称 home_stock，包名 com.homestock.app

目录结构：
```

lib/
├── main.dart
├── app.dart
├── core/
│ ├── constants/ # 设计常量
│ ├── theme/ # 主题
│ ├── router/ # 路由
│ ├── utils/ # 工具类
│ └── extensions/ # 扩展方法
├── data/
│ ├── database/ # Drift 数据库 & 表 & DAO
│ ├── models/ # 数据模型
│ └── repositories/ # 仓库实现
├── domain/
│ ├── entities/ # Freezed 业务实体
│ ├── repositories/ # 仓库抽象接口
│ └── usecases/ # 业务用例
├── presentation/
│ ├── common/widgets/ # 通用组件
│ ├── home/
│ ├── items/
│ ├── locations/
│ ├── alerts/
│ ├── shopping/
│ ├── statistics/
│ ├── search/
│ └── profile/
└── providers/ # Riverpod Provider 注册

```

安装以下依赖：
- flutter_riverpod, riverpod_annotation, riverpod_generator
- go_router
- drift, sqlite3_flutter_libs, path_provider, path
- freezed_annotation, freezed, json_annotation, json_serializable
- build_runner, drift_dev
- flutter_local_notifications
- mobile_scanner
- image_picker
- fl_chart
- flutter_slidable
- shimmer
- intl
- share_plus
- permission_handler

---

## 任务2：设计常量

创建以下常量文件：

### 颜色 (app_colors.dart)
```

主色：#2196F3
成功/正常：#4CAF50，浅底：#E8F5E9
警告/注意：#FF9800，浅底：#FFF3E0
危险/过期：#F44336，浅底：#FFEBEE
页面背景：#FAFAFA
卡片背景：#FFFFFF
主文字：#212121
次要文字：#616161
辅助文字：#9E9E9E
分割线：#EEEEEE
边框：#E0E0E0
禁用：#BDBDBD

分类色：食品#FF8A65 | 日用#4DB6AC | 药品#7986CB | 电器#FFD54F | 衣物#F06292 | 其他#A1887F

```

### 字体 (app_typography.dart)
```

大标题：28px Bold
标题2：24px Bold
标题3：20px Semibold
标题4：18px Semibold
标题5：16px Medium
正文大：16px Regular
正文：14px Regular
正文小：12px Regular
极小：10px Regular
数字展示：32px Bold
数字大：24px Semibold
标签：14px Medium / 12px Medium

```

### 间距 (app_spacing.dart)
```

xs:2 sm:4 md:8 base:12 lg:16 xl:20 xxl:24 xxxl:32 huge:40
页面水平边距：16 卡片内边距：16 卡片间距：12 区块间距：24

```

### 圆角 (app_radius.dart)
```

xs:4 sm:8 md:12 lg:16 xl:20 full:9999

```

### 阴影 (app_shadows.dart)
```

sm: offset(0,1) blur2 opacity5%
md: offset(0,4) blur8 opacity8%
lg: offset(0,8) blur24 opacity12%

```

---

## 任务3：主题配置

基于 Material 3 创建 lightTheme：
- 使用上面定义的颜色
- scaffoldBackgroundColor 用页面背景色
- AppBar：白底、无阴影、标题居中
- Card：白色、无elevation、圆角12
- InputDecoration：白底填充、灰色边框、focus时主色边框2px
- BottomNavigationBar：白底、选中主色、未选中灰色
- Divider：#EEEEEE

---

## 任务4：数据库建表

使用 Drift 创建以下6张表：

### items 表
| 字段 | 类型 | 约束 |
|------|------|------|
| id | integer | PK 自增 |
| name | text | 必填，1-100字符 |
| brand | text | 可选 |
| specification | text | 可选 |
| barcode | text | 可选 |
| category_id | integer | FK→categories |
| location_id | integer | 可选，FK→locations |
| purchase_price | real | 可选 |
| purchase_quantity | integer | 默认1 |
| current_quantity | real | 默认1 |
| unit | text | 默认'件' |
| safety_stock | real | 默认1 |
| purchase_date | dateTime | 可选 |
| purchase_channel | text | 可选 |
| production_date | dateTime | 可选 |
| expiry_date | dateTime | 可选 |
| shelf_life_days | integer | 可选 |
| opened_date | dateTime | 可选 |
| after_open_days | integer | 可选 |
| warranty_date | dateTime | 可选 |
| expiry_alert_days | integer | 默认3 |
| stock_alert | boolean | 默认true |
| images | text | 可选（JSON数组） |
| notes | text | 可选 |
| status | integer | 默认0（0使用中/1用完/2过期/3丢弃） |
| avg_daily_consumption | real | 可选 |
| predicted_empty_date | dateTime | 可选 |
| created_at | dateTime | 默认当前时间 |
| updated_at | dateTime | 默认当前时间 |

### categories 表
id, name, icon(emoji), color(hex), parent_id(可选), sort_order, is_system(bool), created_at

### locations 表
id, name, icon(可选), parent_id(可选), level(1/2/3), full_path, sort_order, created_at

### usage_records 表
id, item_id(FK), type(0入库/1使用/2丢弃/3移动/4调整), quantity, remaining_quantity, operator_name(可选), notes(可选), created_at

### shopping_list 表
id, name, related_item_id(可选), quantity, unit, estimated_price(可选), is_purchased(默认false), is_auto_generated(bool), created_at

### family_members 表
id, name, avatar(可选), role(admin/member), created_at

为 items、usage_records、shopping_list 创建对应的 DAO，包含基础 CRUD 方法。

---

## 任务5：预设数据（App首次启动写入）

### 预设分类
```

食品饮料🍎 #FF8A65：乳制品、肉类、蔬果、零食、饮品、调味品、粮油、速食
日用清洁🧹 #4DB6AC：洗衣、厨房清洁、纸巾、垃圾袋
个护美妆🧴 #F06292：洗护、口腔、护肤、彩妆
药品保健💊 #7986CB：常用药、保健品、医疗器械
家用电器📺 #FFD54F：大家电、小家电、数码
衣物鞋帽👕 #F06292
其他📦 #A1887F

```

### 预设位置
```

厨房🍳：冰箱(冷藏层/冷冻层/门侧)、吊柜(一层/二层/三层)、调料架、水槽下方、台面
卫生间🛁：洗漱台(台面/镜柜/下方)、浴室柜、马桶旁
客厅🛋️：电视柜、茶几(上方/下方)、书架
主卧🛏️：衣柜(上层/中层/下层/抽屉)、床头柜(台面/抽屉)、梳妆台
次卧🛏️：衣柜、书桌
阳台☀️：储物柜(上层/下层)、晾衣区

```

写一个 seed 方法在数据库首次创建时插入这些预设数据，is_system 标记为 true。

---

## 任务6：路由配置

使用 GoRouter 配置以下路由：

带底部导航的（ShellRoute）：
- / → HomePage
- /items → ItemListPage
- /alerts → AlertCenterPage
- /profile → ProfilePage

不带底部导航的：
- /items/add → AddItemPage
- /items/scan → ScanPage
- /items/:id → ItemDetailPage
- /items/:id/edit → EditItemPage
- /locations → LocationOverviewPage
- /locations/:id → LocationDetailPage
- /shopping → ShoppingListPage
- /statistics → StatisticsPage
- /search → SearchPage

每个 Page 先创建空白占位 Widget（显示页面名称即可），后续阶段填充内容。

---

## 任务7：底部导航 & 主壳子

实现 MainScaffold 组件：
- 底部5个Tab：首页(home图标)、物品(inventory图标)、中间录入按钮、提醒(bell图标)、我的(person图标)
- 中间录入按钮使用 FloatingActionButton 样式：56px圆形、主色背景、白色加号图标、比其他Tab凸出
- 使用 BottomAppBar + CircularNotchedRectangle 实现中间凹槽效果
- 点击中间按钮弹出底部弹窗（先写占位，内容Phase2补充）
- Tab 切换无动画（NoTransitionPage）

---

## 任务8：main.dart 入口

- 初始化 WidgetsFlutterBinding
- 初始化时区（timezone包）
- 使用 ProviderScope 包裹 App
- MaterialApp.router 使用 GoRouter
- 设置 locale 为中文
- 加载主题

---

## 验收标准

1. ✅ App 能正常运行在 iOS/Android 模拟器
2. ✅ 底部导航5个Tab可切换，中间按钮凸出显示
3. ✅ 点击中间按钮弹出空白底部弹窗
4. ✅ 数据库创建成功，预设分类和位置数据已写入（可通过日志验证）
5. ✅ 路由可正常跳转（虽然页面是空白占位）
6. ✅ 代码结构清晰，符合 Clean Architecture 分层
7. ✅ 无编译错误，build_runner 代码生成正常
```

***

## 📋 Phase 2：核心 CRUD

```markdown
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

## 任务6：编辑物品页

路由：/items/:id/edit

复用 AddItemPage 的表单结构，但：
- 进入时从数据库读取物品信息，预填所有字段
- AppBar 标题改为"编辑物品"
- 保存时为 update 而非 insert
- 没有"保存并继续添加"按钮
- 位置和分类变更时也要正确更新

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
```

***

## 📋 Phase 3：位置管理 & 提醒系统

```markdown
# HomeStock — Phase 3：位置管理 & 提醒系统

## 前置条件
Phase 1（骨架）和 Phase 2（核心CRUD）已完成。
物品可以录入、查看、编辑、记录使用。

## 本阶段目标
1. 完善位置管理功能（可视化查看、增删改位置结构）
2. 实现提醒中心（过期/库存/补购提醒展示和操作）
3. 接入本地通知（定时检查并推送提醒）

---

## 任务1：位置总览页（LocationOverviewPage）

路由：/locations

### 页面结构
- AppBar 标题"我的家"，右侧"+ 添加空间"按钮
- 网格布局（2列），展示所有一级位置（房间）
- 每个房间卡片：emoji图标(32px) + 名称 + "X件物品"数量
- 卡片样式：灰色背景、圆角12、1:1比例、点击跳转位置详情

### 添加空间
点击"+"弹出 Dialog：输入名称、选择emoji图标、确认后插入 locations 表（level=1）

---

## 任务2：位置详情页（LocationDetailPage）

路由：/locations/:id

### 页面结构
- AppBar 显示位置名称，右侧"编辑布局"按钮
- 如果当前位置有子位置：显示子位置卡片网格（点击进入下一层）
- 如果当前位置是最末层或有物品：显示该位置下的物品列表

### 子位置卡片
与总览页类似，显示子位置名称 + 物品数量

### 物品列表
使用 Phase2 的 ItemCard 组件，展示 location_id = 当前位置ID 的物品
按过期时间排序（快过期的在前面）

### 编辑布局
点击后进入编辑模式：
- 每个子位置卡片右上角显示删除按钮
- 底部显示"+ 添加子位置"按钮
- 支持长按拖拽排序（可选，用 ReorderableListView 实现）

### 添加子位置
弹出 Dialog：输入名称，确认后插入 locations 表（parent_id=当前位置ID，level=当前+1，full_path自动拼接）

---

## 任务3：位置删除逻辑

- 删除位置时检查：该位置及其子位置下是否有物品
- 如有物品：弹窗提示"该位置下有X件物品，请先移走物品再删除"，阻止删除
- 如无物品：确认弹窗后删除该位置及所有子位置

---

## 任务4：提醒中心页（AlertCenterPage）

路由：/alerts（底部Tab第四个）

### 页面结构
- AppBar 标题"提醒中心"，右侧"全部已读"按钮
- 顶部 TabBar（5个Tab）：全部 | 过期 | 库存 | 补购 | 其他
- TabBarView 内容为对应的提醒列表

### 提醒数据来源（实时从数据库查询，非单独存储）

**过期提醒：**
查询条件：status=0(使用中) AND expiry_date 不为空 AND expiry_date - expiry_alert_days <= today
显示内容：🔴/🟡图标 + "XXX还剩X天过期" + 位置 + 建议操作

**库存提醒：**
查询条件：status=0 AND current_quantity <= safety_stock AND stock_alert=true
显示内容：📦图标 + "XXX库存不足" + 剩余量 + 预计用完时间

**补购提醒：**
查询条件：status=1(已用完) 且最近7天变为用完的
显示内容：🛒图标 + "XXX已用完" + 上次购买信息

**其他提醒：**
保修即将到期：warranty_date - 30天 <= today

### AlertCard 组件
- 左侧4px状态色条（红/橙/蓝）
- 内容：图标 + 标题 + 描述 + 位置信息
- 底部操作按钮行（根据类型不同）：
  - 过期提醒：[今天用掉] [已丢弃] [忽略]
  - 库存提醒：[加入购物清单] [已知晓]
  - 补购提醒：[加入购物清单] [再次购买]

### 操作按钮逻辑
- 「今天用掉」→ 弹出 UsageDialog
- 「已丢弃」→ 将物品 status 改为 3，记录 usage_record(type=2丢弃)
- 「加入购物清单」→ 添加到 shopping_list
- 「忽略」→ 从列表中移除（本次会话不再显示，但不改数据）

### 空状态
某个Tab下没有提醒时显示：😊 emoji + "一切安好，没有待处理的提醒"

---

## 任务5：本地通知服务

### 初始化
在 main.dart 中初始化 flutter_local_notifications：
- Android channel: expiry_channel(过期提醒), stock_channel(库存提醒)
- iOS 请求通知权限

### 通知调度服务（NotificationScheduler）

创建一个服务类，提供以下功能：

**scheduleExpiryNotification(item)**
- 计算提醒日期 = expiry_date - expiry_alert_days
- 如果提醒日期 > 今天：使用 zonedSchedule 设置定时通知
- 通知标题："⚠️ 物品即将过期"
- 通知内容："[物品名] 将在X天后过期，请及时处理"
- payload: "item:{id}" 用于点击跳转

**cancelNotification(itemId)**
- 取消该物品的所有已调度通知

**rescheduleAllNotifications()**
- 取消所有通知 → 重新遍历所有 status=0 且有 expiry_date 的物品 → 逐个调度
- 应在以下时机调用：App启动时、物品新增/编辑/删除时

### 每日检查任务
- App每次打开时（在 main 或 HomePage initState 中）执行一次全量检查
- 检查所有物品的过期状态，如果 expiry_date < today 且 status 还是 0，自动更新 status=2
- 重新调度所有通知

### 通知点击处理
点击通知后根据 payload 跳转到对应物品详情页

---

## 任务6：Tab Badge 角标

底部导航"提醒"Tab 上显示未处理提醒数量角标：
- 计算方式：过期提醒数 + 库存提醒数
- 数量为0时隐藏角标
- 使用 Badge 组件

---

## 验收标准

1. ✅ 位置总览页正确显示所有房间，带物品数量统计
2. ✅ 可以逐层进入位置详情，查看该位置下的物品
3. ✅ 可以添加/删除位置，有物品时阻止删除
4. ✅ 提醒中心按Tab分类显示不同类型提醒
5. ✅ 提醒卡片的操作按钮功能正确（丢弃/加购物清单等）
6. ✅ 通知权限获取正常
7. ✅ 添加有过期时间的物品后，通知被正确调度
8. ✅ 到达提醒时间时收到本地通知
9. ✅ 点击通知跳转到物品详情页
10. ✅ 底部Tab角标正确显示提醒数量
```

***

## 📋 Phase 4：智能功能

```markdown
# HomeStock — Phase 4：智能功能

## 前置条件
Phase 1-3 已完成。物品CRUD、位置管理、提醒通知均已可用。

## 本阶段目标
实现首页 Dashboard、搜索功能、购物清单、消耗预测算法。
让App从「记录工具」升级为「智能助手」。

---

## 任务1：首页 Dashboard（HomePage）

路由：/（底部Tab第一个）

### 布局（CustomScrollView，支持下拉刷新）

**AppBar区域：**
- 左侧显示"我的家"标题
- 右侧通知铃铛图标（带Badge数量）+ 头像

**搜索栏：**
- 使用 AppSearchBar 组件，readOnly=true
- 点击跳转 /search 页面

**警告摘要区域：** 标题"⚠️ 需要关注"
- 2×2 网格，4个 StatCard：
  - 🔴 即将过期 | X件 | "最近：牛奶，还剩2天"
  - 📦 库存不足 | X件 | "最近：洗衣液，预计3天用完"
  - 🛒 待购清单 | X项
  - 📊 本月消费 | ¥X,XXX | "比上月↑X%"
- 每个卡片可点击，跳转对应页面

**快捷空间入口：** 标题"📍 快捷查看"
- 横向滚动的房间卡片列表
- 每个卡片：emoji + 房间名 + 物品数
- 点击跳转 /locations/:id

**最近动态：** 标题"📅 最近动态"
- 时间线样式，显示最近5条 usage_records
- 格式："今天 10:30 用完了「厨房纸巾」"
- 底部"查看全部→"

### 数据获取
创建 HomeController (Riverpod)，加载：
- expiringCount: status=0 且 7天内过期的数量
- lowStockCount: status=0 且 current_quantity <= safety_stock 数量
- shoppingCount: shopping_list 中 is_purchased=false 数量
- monthlyExpense: 本月 purchase_date 的物品 total_price 总和
- spaces: 所有 level=1 的位置 + 各自的物品数
- recentActivities: 最近5条 usage_records（关联物品名）

---

## 任务2：搜索页（SearchPage）

路由：/search

### 页面结构
- 顶部搜索输入框（自动聚焦，带清除按钮）
- 输入前：显示搜索历史 + 热门搜索
- 输入时：实时搜索（防抖300ms）

### 搜索逻辑
搜索范围：items 表的 name、brand 字段 + locations 表的 full_path
查询：LIKE '%keyword%'
结果按相关度排序（名称匹配优先于品牌匹配）

### 结果展示
使用 ItemCard 组件展示，突出位置信息（方便「找东西」场景）
每个结果卡片增加一个"导航到位置"的小标签

### 无结果
AppEmptyState: "没有找到 XXX 相关物品" + [手动添加"XXX"] 按钮

### 搜索历史
- 本地存储（SharedPreferences 或数据库）
- 最多保留10条
- 支持清除历史

---

## 任务3：购物清单页（ShoppingListPage）

路由：/shopping

### 页面结构
- AppBar 标题"购物清单"，右侧"分享清单"按钮
- 顶部 Tab：待购 | 已购 | 历史

### 待购 Tab

**系统推荐区域：** 标题"系统推荐（根据消耗预测）"
- 显示 is_auto_generated=true 且 is_purchased=false 的项
- 每项：名称 + 数量+单位 + 上次价格 + 推荐原因（"预计3天后用完"/"已用完"）

**手动添加区域：**
- 显示 is_auto_generated=false 且 is_purchased=false 的项
- 每项：名称 + 数量

**底部：**
- 预估总消费：¥ XXX（sum of estimated_price × quantity）
- 「+ 添加物品」按钮
- 「标记全部已购买」按钮

### 添加到购物清单
弹出 Dialog：
- 输入物品名称（支持从已有物品中搜索选择）
- 数量 + 单位
- 预估价格（可选）
- 确认添加

### 标记已购买
- 每项左侧有 Checkbox
- 勾选后该项移到"已购"Tab
- 更新 is_purchased=true, purchased_at=now

### 已购 Tab
显示最近已购项，支持"一键入库"操作：
- 点击某项 → 跳转到 AddItemPage，预填名称、数量、价格

### 分享功能
将待购清单生成纯文本，通过 share_plus 分享：
```

📋 购物清单 (2024-01-25)

- 洗衣液 3kg × 1
- 纯牛奶 250ml × 6
- 厨房纸巾 × 2

```

---

## 任务4：消耗预测算法

创建 ConsumptionPredictionService 类：

### calculateAvgDailyConsumption(itemId)
```

1. 查询该物品所有 type=1(使用) 的 usage\_records，按时间排序
2. 如果记录 < 2 条：
   用 (purchase\_quantity - current\_quantity) / (today - created\_at天数) 估算
3. 如果记录 >= 2 条：
   加权平均法（越近的记录权重越高）：
   遍历相邻两条记录，计算 rate = quantity / 间隔天数
   weight = 记录序号（越新序号越大）
   avg = sum(rate × weight) / sum(weight)
4. 返回日均消耗量

```

### predictEmptyDate(item, avgDailyConsumption)
```

如果 avgDailyConsumption <= 0：返回 null
daysRemaining = current\_quantity / avgDailyConsumption
return today + daysRemaining天

```

### 更新时机
在以下场景调用并更新 items 表的 avg_daily_consumption 和 predicted_empty_date：
- 记录使用后
- App启动时批量更新所有 status=0 的物品

---

## 任务5：购物清单自动生成

创建定时任务（App启动时 + 每次记录使用后执行）：

```

遍历所有 status=0 的物品：
IF (current\_quantity <= safety\_stock)
OR (predicted\_empty\_date != null AND predicted\_empty\_date - today <= 7天)
THEN:
检查 shopping\_list 中是否已存在 related\_item\_id = 该物品ID 且 is\_purchased=false
如果不存在：
INSERT shopping\_list (
name = 物品name,
related\_item\_id = 物品id,
quantity = 物品purchase\_quantity,
unit = 物品unit,
estimated\_price = 物品purchase\_price,
is\_auto\_generated = true
)

```

---

## 验收标准

1. ✅ 首页正确显示4个统计卡片，数据实时准确
2. ✅ 首页空间入口横向滚动，点击进入位置详情
3. ✅ 首页最近动态展示正确
4. ✅ 搜索实时响应，结果突出位置信息
5. ✅ 搜索历史可保存和清除
6. ✅ 购物清单区分系统推荐和手动添加
7. ✅ 手动添加购物项功能正常
8. ✅ 标记已购买功能正确
9. ✅ 分享清单生成格式正确
10. ✅ 消耗预测算法正确计算日均消耗和预计用完日期
11. ✅ 系统自动生成购物推荐在合适时机触发
12. ✅ 详情页的"预计用完时间"显示正确
```

***

## 📋 Phase 5：增强功能

```markdown
# HomeStock — Phase 5：增强功能

## 前置条件
Phase 1-4 已完成。核心功能已可用，有智能推荐。

## 本阶段目标
增加扫码录入、数据统计图表、数据导出功能。

---

## 任务1：扫码录入（ScanPage）

路由：/items/scan

### 页面结构
- 全屏相机预览（使用 mobile_scanner）
- AppBar 黑色背景，标题"扫码录入"，右侧闪光灯按钮
- 中间扫码框（虚线方框引导）
- 底部半透明黑色区域："将条形码对准框内，自动识别"
- 扫描中的 loading 遮罩

### 扫码逻辑
1. 识别到条形码后：
   - 播放震动反馈（HapticFeedback）
   - 暂停扫码
   - 跳转到 /items/add 页面，通过路由参数传递 barcode 值
2. AddItemPage 接收到 barcode 参数后：
   - 预填 barcode 字段
   - （MVP阶段不对接商品信息库，只是存储条码值）
   - 后续可扩展：调用公开商品API查询名称/品牌

### 重复扫码检测
跳转前检查数据库中是否已存在该 barcode 的物品：
- 如果存在：弹出 Dialog "该商品已录入(名称)，是否查看详情？" → [查看详情] [继续新增]
- 不存在：正常跳转录入

---

## 任务2：数据统计页（StatisticsPage）

路由：/statistics

### 页面结构
- AppBar 标题"数据统计"
- 顶部时间维度切换 Tab：本周 | 本月 | 本年
- 可滚动内容区

### 区块1：消费概览
- 大数字显示总消费金额
- 趋势对比文字："较上月 ↑12% (+¥305)" 或 "较上月 ↓8%"
- 折线图（fl_chart）：展示近6个月的消费趋势
  - X轴：月份
  - Y轴：金额
  - 数据来源：按月汇总 items 表中 purchase_date 在对应月份的 total_price

### 区块2：分类占比
- 水平条形图或饼图
- 数据：按 category 分组汇总 total_price
- 每个分类显示：名称 + 彩色条 + 百分比 + 金额
- 使用对应分类色

### 区块3：浪费统计
- 本月过期丢弃件数和金额
- 数据来源：usage_records 中 type=2(丢弃) 且 created_at 在本月的记录，关联 items 表获取价格
- 列出具体丢弃物品（名称 + 价格 + 原因标签）
- 底部建议文字（如："💡 建议：减少叶菜类一次购买量"）

### 区块4：消耗排行
- Top 5 消耗最多的物品
- 数据：按 item_id 汇总 usage_records 中 type=1 的 quantity，取 Top5
- 显示：排名 + 名称 + 消耗量 + 对应金额

### 数据查询逻辑
根据选中的时间维度（本周/本月/本年）确定日期范围，所有查询限定在该范围内。

---

## 任务3：数据导出

在「我的」页面添加"数据导出"入口。

### 导出格式
生成 CSV 文件，包含以下列：
物品名称、品牌、分类、位置、购买价格、购买数量、当前剩余、单位、购买日期、过期日期、状态

### 导出流程
1. 点击"导出数据"
2. 弹窗选择导出范围：全部物品 / 仅使用中 / 仅已过期
3. 生成 CSV 文件存到临时目录
4. 调用系统分享（share_plus）让用户选择保存位置或发送

---

## 任务4：「我的」页面完善（ProfilePage）

路由：/profile（底部Tab第五个）

### 页面结构
- 顶部个人信息区：头像 + 名称 + 角色
- 功能入口列表：
  - 🏠 空间管理 → /locations
  - 🏷️ 分类管理 → 分类管理页
  - 👨‍👩‍👧‍👦 家庭成员 → 成员管理页
  - 📊 数据统计 → /statistics
  - 🛒 购物清单 → /shopping
  - 🔔 提醒设置 → 提醒偏好设置页
  - 📤 数据导出 → 触发导出流程
  - ℹ️ 关于 → 关于页

### 分类管理页
- 列表展示所有分类（含子分类）
- 支持添加自定义分类（name + emoji + color选择）
- 系统预设分类不可删除（is_system=true），可以隐藏
- 自定义分类可编辑/删除

### 家庭成员管理页
- 列表展示所有成员
- 添加成员：名称 + 头像（可选，从图库选择）
- 编辑/删除成员
- 成员用于记录"谁使用了物品"

### 提醒设置页
- 全局开关：是否开启通知
- 过期提醒默认提前天数（修改后应用到所有未单独设置的物品）
- 提醒时间段设置（如：只在8:00-22:00推送）

---

## 验收标准

1. ✅ 扫码功能正常识别条形码
2. ✅ 扫到已有条码时提示并可跳转详情
3. ✅ 扫码后正确跳转录入页并预填条码
4. ✅ 统计页折线图正确显示消费趋势
5. ✅ 分类占比图数据准确
6. ✅ 浪费统计正确计算过期丢弃金额
7. ✅ 消耗排行正确
8. ✅ 时间维度切换后图表数据刷新
9. ✅ CSV 导出文件格式正确，分享功能正常
10. ✅ 分类管理可增删改
11. ✅ 家庭成员管理正常
12. ✅ 提醒设置保存有效
```

***

## 📋 Phase 6：体验打磨

```markdown
# HomeStock — Phase 6：体验打磨

## 前置条件
Phase 1-5 所有功能已完成。App 功能完整可用。

## 本阶段目标
提升用户体验：空状态、加载状态、动画、错误处理、首次使用引导。
让 App 从「能用」变成「好用」。

---

## 任务1：空状态设计

为以下场景添加专属空状态（使用 AppEmptyState 组件）：

| 场景 | emoji | 标题 | 描述 | 操作按钮 |
|------|-------|------|------|----------|
| 物品列表为空 | 📦 | 还没有添加物品 | 扫一扫或手动添加第一件物品吧 | + 添加第一件物品 |
| 搜索无结果 | 🔍 | 没有找到"XX" | 试试其他关键词？ | + 手动添加"XX" |
| 提醒为空 | 😊 | 一切安好 | 没有待处理的提醒，物品都在保质期内 | 无 |
| 购物清单为空 | 🛒 | 购物清单为空 | 物品用完或库存不足时会自动推荐 | 无 |
| 某位置无物品 | 🏠 | 这里还没有物品 | 添加物品时选择存放到这里 | 无 |
| 统计无数据 | 📊 | 数据不足 | 添加更多物品后可查看统计 | 无 |

---

## 任务2：加载状态（骨架屏）

为以下页面添加 Shimmer 骨架屏加载效果：

### 物品列表骨架屏
模拟3-5个 ItemCard 的占位形状：
- 左侧方块（图片占位）
- 右侧3行长短不一的条形（文字占位）
- 使用 shimmer 包实现闪光扫过效果

### 首页骨架屏
- 搜索栏占位
- 4个方块（StatCard占位）
- 横向条形列表（空间卡片占位）
- 竖向条形列表（动态占位）

### 详情页骨架屏
- 大方块（图片区）
- 文字条形若干

### 加载时机
- 数据库查询期间显示骨架屏
- 查询完成后替换为实际内容
- 使用 Riverpod 的 AsyncValue.when(loading/error/data) 控制

---

## 任务3：错误处理

### 全局错误捕获
- 在 ProviderScope 中添加 ProviderObserver 监听错误
- 未捕获异常记录到本地日志

### 页面级错误
当 AsyncValue 为 error 时，显示错误状态：
- 错误图标 + "加载失败" + 错误信息 + [重试] 按钮

### 操作级错误
保存/删除等操作失败时：
- 显示 SnackBar 提示错误原因
- 提供重试选项

### 网络错误（为后续联网做预留）
统一的网络错误提示组件

---

## 任务4：删除撤销

所有删除操作改为：
1. 删除后不立即永久删除，而是标记软删除（或暂存）
2. 底部显示 SnackBar："已删除「XX」" + [撤销] 按钮
3. SnackBar 持续5秒
4. 5秒内点击撤销 → 恢复数据
5. 5秒后或用户操作其他 → 真正执行删除

---

## 任务5：动画 & 微交互

### 页面转场
- Tab切换：渐隐渐显 200ms
- Push新页面：从右侧滑入 300ms
- 底部弹窗：从底部滑入 350ms + 弹性曲线
- Dialog：缩放淡入 200ms

### 列表动画
- 新物品入库后，列表头部新增卡片带入场动画（从上方淡入+下移）
- 删除物品卡片带退出动画（向左滑出）
- 使用 AnimatedList 或 implicitly animated widgets

### 数字动画
- StatCard 中的数字变化时使用 AnimatedSwitcher（旧数字上移消失，新数字下移出现）
- 进度条变化使用 AnimatedContainer 平滑过渡

### 按钮反馈
- 所有按钮按下时缩放 0.95（200ms）
- 卡片按下时轻微缩放 0.98 + 阴影变小

### 下拉刷新
- 首页和物品列表支持 RefreshIndicator
- 刷新时重新加载数据

---

## 任务6：首次使用引导

App第一次打开时（通过 SharedPreferences 判断 is_first_launch）：

### 引导流程（3步）

**Step 1：欢迎页**
- 标题："欢迎使用 HomeStock"
- 描述："轻松管理家庭物品，再也不担心过期浪费"
- 插画/大emoji
- [开始设置] 按钮

**Step 2：选择房间布局**
- 标题："你家有哪些空间？"
- 显示预设房间列表（带Checkbox）
- 用户勾选自己有的房间
- 支持添加自定义房间
- 选中的房间及其子位置会写入数据库

**Step 3：添加第一件物品**
- 标题："试着添加第一件物品"
- 引导跳转到扫码或手动录入
- 也可跳过

完成后设置 is_first_launch = false，进入首页。

---

## 任务7：性能优化

### 列表优化
- 物品列表使用 ListView.builder（懒加载）
- 加载超过100条时分页（每页20条，滚动到底加载更多）
- 图片使用缓存，避免重复读取文件

### 数据库优化
- 为常用查询字段添加索引：items.status, items.category_id, items.location_id, items.expiry_date
- usage_records.item_id, usage_records.created_at 添加索引
- 批量更新消耗预测时使用事务

### 内存优化
- 大列表使用 AutoDispose 的 provider
- 页面不可见时释放图片资源

### 启动优化
- 数据库初始化和通知初始化并行执行
- 预设数据只在首次安装时写入

---

## 任务8：细节完善

### 输入体验
- 数字输入框只允许数字和小数点
- 日期选择器默认日期合理（购买日期默认今天，过期日期默认未来）
- 表单页面退出时如有未保存更改，弹窗提示"是否放弃修改？"

### 列表体验
- 列表滚动到顶部时隐藏"回到顶部"按钮，滚动超过一屏后显示
- 筛选/排序变更后列表自动滚动到顶部

### 数据一致性
- 物品删除时，关联的 usage_records 一并删除
- 物品删除时，shopping_list 中 related_item_id 对应项标记为无关联
- 位置删除时，该位置下物品的 location_id 置为 null

---

## 验收标准

1. ✅ 所有空状态页面显示友好提示和引导操作
2. ✅ 数据加载时显示骨架屏而非空白或转圈
3. ✅ 操作失败有错误提示和重试选项
4. ✅ 删除后5秒内可撤销
5. ✅ 页面转场有平滑动画
6. ✅ 数字变化有过渡动画
7. ✅ 按钮/卡片有触摸反馈
8. ✅ 首次使用引导流程完整可走通
9. ✅ 引导选择的房间正确写入数据库
10. ✅ 100+物品时列表滚动流畅无卡顿
11. ✅ 表单退出有未保存提示
12. ✅ 数据删除时关联数据正确清理
13. ✅ 整体使用感受流畅、无明显bug
```

***

## 使用方式总结

| 阶段      | 给 Trae 的时机    | 预计工作量 |
| :------ | :------------ | :---- |
| Phase 1 | 项目开始          | 1-2天  |
| Phase 2 | Phase 1 验收通过后 | 2-3天  |
| Phase 3 | Phase 2 验收通过后 | 2天    |
| Phase 4 | Phase 3 验收通过后 | 2-3天  |
| Phase 5 | Phase 4 验收通过后 | 2天    |
| Phase 6 | Phase 5 验收通过后 | 2-3天  |

**使用建议：**

- 每个 Phase 单独粘贴给 Trae
- 完成后自己验收，有问题追问 Trae 修复
- 确认通过后再给下一个 Phase
- 如果某个任务太复杂，可以只给那个任务的部分让 Trae 先做

