# HomeStock App Phase 1：基础骨架 - 实现计划

## 项目背景
根据 [Phase 1：基础骨架.md](file:///Users/lwh/Desktop/Project/ServerHomeWare/doc/appPhase/Phase%201%EF%BC%9A%E5%9F%BA%E7%A1%80%E9%AA%A8%E6%9E%B6.md) 的需求，需要创建一个 Flutter App 基础骨架，帮助用户管理家庭物品的全生命周期。

## 技术选型
- Flutter 3.x + Dart
- 状态管理：Riverpod 2.x（code generation 模式）
- 本地数据库：Drift（SQLite）
- 路由：GoRouter
- 数据类：Freezed
- UI风格：Material 3
- 架构：Clean Architecture（data / domain / presentation 三层）

## 任务分解

### 任务1：项目初始化
- 创建 Flutter 项目 `home_stock`，包名 `com.homestock.app`
- 安装所有必要依赖

### 任务2：创建目录结构
按照 Clean Architecture 分层创建目录：
- lib/core/（设计常量、主题、路由、工具类）
- lib/data/（数据库、数据模型、仓库实现）
- lib/domain/（业务实体、仓库接口、业务用例）
- lib/presentation/（UI组件、页面）
- lib/providers/（Riverpod Provider）

### 任务3：设计常量
创建以下常量文件：
- app_colors.dart - 颜色定义
- app_typography.dart - 字体定义
- app_spacing.dart - 间距定义
- app_radius.dart - 圆角定义
- app_shadows.dart - 阴影定义

### 任务4：主题配置
创建 Material 3 主题配置

### 任务5：数据库建表
使用 Drift 创建6张表：
- items - 物品表
- categories - 分类表
- locations - 位置表
- usage_records - 使用记录表
- shopping_list - 购物清单表
- family_members - 家庭成员表

### 任务6：预设数据
创建 seed 方法，首次启动时插入预设分类和位置数据

### 任务7：路由配置
使用 GoRouter 配置路由，包含底部导航和全屏页面

### 任务8：底部导航 & 主壳子
实现 MainScaffold 组件，包含5个 Tab 和中间浮动按钮

### 任务9：页面占位
为所有路由创建空白页面占位

### 任务10：main.dart 入口
配置应用入口，初始化 ProviderScope、路由、主题等

## 文件清单

### 新增文件
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   └── app_shadows.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── utils/
│   │   └── date_utils.dart
│   └── extensions/
│       └── string_extensions.dart
├── data/
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── tables/
│   │   │   ├── items.dart
│   │   │   ├── categories.dart
│   │   │   ├── locations.dart
│   │   │   ├── usage_records.dart
│   │   │   ├── shopping_list.dart
│   │   │   └── family_members.dart
│   │   └── daos/
│   │       ├── item_dao.dart
│   │       ├── category_dao.dart
│   │       ├── location_dao.dart
│   │       ├── usage_record_dao.dart
│   │       └── shopping_list_dao.dart
│   ├── models/
│   └── repositories/
│       └── item_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── item.dart
│   │   ├── category.dart
│   │   ├── location.dart
│   │   ├── usage_record.dart
│   │   └── shopping_item.dart
│   ├── repositories/
│   │   └── item_repository.dart
│   └── usecases/
│       └── get_items.dart
├── presentation/
│   ├── common/
│   │   └── widgets/
│   │       └── main_scaffold.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── items/
│   │   ├── item_list_page.dart
│   │   ├── item_detail_page.dart
│   │   ├── add_item_page.dart
│   │   └── edit_item_page.dart
│   ├── alerts/
│   │   └── alert_center_page.dart
│   ├── profile/
│   │   └── profile_page.dart
│   ├── locations/
│   │   ├── location_overview_page.dart
│   │   └── location_detail_page.dart
│   ├── shopping/
│   │   └── shopping_list_page.dart
│   ├── statistics/
│   │   └── statistics_page.dart
│   └── search/
│       └── search_page.dart
└── providers/
    ├── item_providers.dart
    └── app_providers.dart
```

## 依赖安装
需要安装以下依赖：
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

## 风险与注意事项
1. Flutter 版本兼容性：确保使用 Flutter 3.x 稳定版
2. 代码生成：需要正确配置 build_runner 脚本
3. 数据库初始化：确保首次启动时正确创建表和预设数据
4. 路由配置：注意 ShellRoute 和普通路由的区别

## 验收标准
1. App 能正常运行在 iOS/Android 模拟器
2. 底部导航5个Tab可切换，中间按钮凸出显示
3. 点击中间按钮弹出空白底部弹窗
4. 数据库创建成功，预设分类和位置数据已写入
5. 路由可正常跳转（虽然页面是空白占位）
6. 代码结构清晰，符合 Clean Architecture 分层
7. 无编译错误，build_runner 代码生成正常