# 单页首页四分区（过期/临期/库存/全部）实现

> 日期：2026-06-30  
> 范围：移除底部 Tab，首页单页展示四分类横向卡片，数据来自 API

---

## 技术开发文档

### 实现方案

1. **产品形态**：取消四 Tab 底栏，登录后直接进入单页首页 `/`
2. **首页结构**：
   - 固定顶栏：头像（个人中心）| 搜索框 | 添加入库
   - 垂直四分区：已过期 / 临期 / 库存不足 / 全部（最近入库）
   - 每区横向 ScrollView + 右上角「查看全部」
3. **数据来源（API）**：
   | 分区 | 接口 |
   |------|------|
   | 已过期 | `GET /api/v1/alerts/expired`（新增） |
   | 临期 | `GET /api/v1/alerts/expiring?days=7` |
   | 库存不足 | `GET /api/v1/alerts/low-stock` |
   | 全部 | `GET /api/v1/items?status=0&sort_by=created_at&sort_order=desc` |
4. **主题**：新增 `communityWarm` 居家暖色，默认替换卡通主题；米白底 + 浅米色模块分割 + 轻投影卡片
5. **查看全部**：`/home/section/:section` 竖向网格完整列表

### 后端改动

| 文件 | 变更 |
|------|------|
| `alert_repo.py` | 新增 `get_expired_items` |
| `alert_service.py` | 新增 `get_expired_items_list`；三类列表附加 `preview_image` |
| `alerts.py` | 新增 `GET /alerts/expired` |
| `alert.py` schema | `ExpiredItemResponse`；列表响应增加 `preview_image` |

### 客户端改动

| 文件 | 变更 |
|------|------|
| `alert_service.dart` | 新建，封装 alerts API |
| `item_service.dart` | `getItems` 支持筛选/排序 query |
| `home_section.dart` | 分区枚举与卡片模型 |
| `home_constants.dart` | 布局常量 |
| `home_sections_provider.dart` | 四分区并行拉取 |
| `home_page.dart` | 重写为单页四分区 |
| `home_top_bar.dart` 等 widgets | 顶栏、分区、卡片、骨架屏 |
| `home_section_list_page.dart` | 查看全部页 |
| `app_router.dart` | 移除 ShellRoute 底栏 |
| `app_color_palette.dart` / `app_theme_variant.dart` | communityWarm 默认主题 |
| `app_theme_background.dart` | 暖色主题纯色底 |

### 影响范围

- 底部 Tab 移除：`/items`、`/profile`、`/alerts` 改为 push 全屏页（个人中心从头像进入）
- 原首页统计/空间/动态模块已移除
- 仍可通过路由直接访问物品列表、提醒中心等

---

## 提测开发文档

### 测试点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 登录后进首页 | 无底部 Tab，米白底四分区 |
| T2 | 已过期/临期/库存/全部 | 各分区横向可滑，卡片含图+标题+标签 |
| T3 | 下拉刷新 | 重新请求 API |
| T4 | 点击卡片 | 进入物品详情 |
| T5 | 查看全部 | 进入 `/home/section/{type}` 网格列表 |
| T6 | 顶栏头像/搜索/+ | 个人中心 / 搜索 / 添加入库 |
| T7 | 无数据分区 | 显示「暂无xx物品」 |
| T8 | API 失败 | 分区或页面显示错误与重试 |

### 验证方式

1. 启动后端 + 客户端，确保有登录态与家庭数据
2. 制造过期、临期、低库存物品，确认各分区有数据
3. 新入库物品出现在「全部」分区最前

### 注意事项

- 需后端部署 `GET /alerts/expired` 新接口
- 临期默认 7 天，常量 `HomeConstants.expiringDays`
- 首页预览每区最多 10 条

---

## 补充（2026-06-30）：个人中心快捷入口

移除底部 Tab 后，在 `ProfilePanelPage` / `ProfilePage` 增加：

| 入口 | 路由 | 说明 |
|------|------|------|
| 物品列表 | `/items` | 原 Tab「物品」 |
| 提醒中心 | `/alerts` | 原 Tab「提醒」，显示未读角标 |
| 通知中心 | `/notifications` | 系统与家庭消息 |

**测试点**：个人中心 → 物品列表 / 提醒中心可正常 push 进入；有未读提醒时角标显示。

---

## 补充（2026-06-30）：Android 构建修复

| 问题 | 修复 |
|------|------|
| Kotlin 2.0 编译器 vs stdlib 2.2 不兼容 | `settings.gradle.kts` 声明 KGP **2.2.20**；`app` 使用 `org.jetbrains.kotlin.android` |
| 插件子工程 Kotlin 版本不一致 | `build.gradle.kts` 统一 `resolutionStrategy` 强制 2.2.20 |
| `home_sections_provider.dart` import 路径错误 | `../../core` → `../../../core` |
| `const config = configs[n]` 编译错误 | 改为 `final config` |

验证：`flutter build apk --debug` 成功。

---

## 补充（2026-06-30）：首页运行时修复

| 问题 | 修复 |
|------|------|
| 横向卡片 `BoxConstraints infinite width` | `HomeItemCard` 用 `SizedBox` 固定宽 148；横向列表显式传 `width` |
| `/alerts/expired` 404（后端未重启） | 客户端回退：拉取物品列表并按 `expiry_date` 筛选已过期 |
| AlertService 404 解析 | 优先识别 HTTP 404，避免误报 message=success |

---

## 补充（2026-06-30）：首页分区 UI 与封面补全

### 改动点

| 问题 | 修复 |
|------|------|
| 分区标题文案长短不一，视觉不统一 | `HomeSectionHeader` 改为「图标 + 主标题 + 固定副标题 + 件数」统一布局 |
| 已过期/临期/库存不足无数据仍展示 | `homeSectionsProvider` 过滤空提醒分区，仅保留有数据的前三类 + 「全部」 |
| 「全部」分区物品无封面图 | 新增 `HomeSectionImageEnricher`：API 无 `preview_image` 时从本地 Drift `items.images` 补全；首页加载前同步物品 |

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| `home_section.dart` | `HomeSectionConfig` 增加 icon/accentColor/subtitle；`HomeSectionItem.copyWith` |
| `home_section_header.dart` | 统一头部布局 |
| `home_section_image_enricher.dart` | 本地封面补全 |
| `home_sections_provider.dart` | 同步、补全、过滤空分区 |
| `home_item_section.dart` | 传递 config + itemCount |
| `home_page.dart` | 骨架屏改为 2 段 |

### 提测

| ID | 场景 | 预期 |
|----|------|------|
| T9 | 三类提醒均无数据 | 首页仅展示「全部」分区 |
| T10 | 部分提醒有数据 | 只展示有数据的分区 + 「全部」 |
| T11 | 分区标题 | 各分区头部高度一致，含图标与副标题 |
| T12 | 全部物品有本地图无 API preview | 卡片显示本地封面 |
| T13 | 查看全部页 | 封面补全与首页一致 |

---

## 补充（2026-06-30）：分区双排横向滚动

### 改动点

| 问题 | 修复 |
|------|------|
| 每个分类仅单行卡片，展示太少 | 改为 **2 行 × 水平滚动**：每列上下 2 张卡片，左右滑动查看更多 |

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| `home_constants.dart` | `previewRowCount`、`twoRowListHeight` 等双排常量 |
| `home_two_row_scroll_grid.dart` | 双排横向 `GridView` 组件 |
| `home_item_section.dart` | 使用双排网格替代单行 `ListView` |
| `home_section_shimmer.dart` | 骨架屏同步双排布局 |

### 提测

| ID | 场景 | 预期 |
|----|------|------|
| T14 | 分区物品 ≥ 2 | 首屏可见上下两行，可左右滑动 |
| T15 | 分区物品 1 件 | 仅首行有卡片，次行空白 |
| T16 | 骨架屏 | 加载中与双排布局高度一致 |

---

## 补充（2026-06-30）：无图物品占位封面

### 改动点

| 问题 | 修复 |
|------|------|
| 无图时灰色 broken 图标，像缺图错误 | 新增 `ItemPlaceholderCover`：分类 emoji + 暖色渐变 + 名称首字角标 |
| 首页缺分类 icon/颜色 | `HomeSectionImageEnricher` 从本地 Drift 分类表补全 |

### 新增/修改文件

| 文件 | 变更 |
|------|------|
| `item_placeholder_helper.dart` | emoji / 颜色 / 首字解析 |
| `item_placeholder_cover.dart` | 共享占位封面组件 |
| `home_item_card.dart` | 无图时使用占位封面 |
| `home_section.dart` | `categoryIcon` / `categoryColorHex` 字段 |
| `home_section_image_enricher.dart` | 补全分类元数据 |

### 提测

| ID | 场景 | 预期 |
|----|------|------|
| T17 | 无图 + 有分类 | 显示分类 emoji + 分类色渐变 + 名称首字 |
| T18 | 无图 + 无分类 | 名称启发式 emoji（食→🍎 等）+ 暖色兜底 |
| T19 | 有图 | 仍显示真实图片，不受影响 |
