
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