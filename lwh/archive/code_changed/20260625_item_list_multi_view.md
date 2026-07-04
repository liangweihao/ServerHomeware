# 物品列表多视图改造（方向 B 阶段 1）

## 技术开发文档

### 背景

用户反馈物品列表仍是「传统 ListView」，虽外壳卡通化，但未回答「这是什么」「我为什么现在看它」。采用方向 B：四种浏览模式，每种对应不同心智模型。

### 实现方案

#### 1. 浏览模式 `ItemListViewTab`

| Tab | 用户问题 | 布局 |
|-----|----------|------|
| 要处理 | 什么需要我管？ | 理由优先列表，仅 `urgency >= 50` |
| 按空间 | 东西在哪？ | 按顶级位置分组 + 3 列紧凑网格 |
| 按分类 | 这类有什么？ | 按分类分组 + 理由优先列表 |
| 全部 | 档案总览 | 理由优先 + 状态 Chip 筛选 + 紧急优先排序 |

#### 2. 出现理由 `ItemListReason`

`item_list_reason_helper.dart` 计算每件物品的：
- emoji + 文案（还剩 N 天 / 库存不足 / 新添加 / 库存充足…）
- 紧急度 0–100
- `isActionable` 用于「要处理」Tab 筛选

#### 3. 数据层 `item_list_providers.dart`

- 从 `item_list_page.dart` 抽离筛选 StateProvider
- `actionItemsProvider` / `spaceGroupedItemsProvider` / `categoryGroupedItemsProvider`
- `itemListMetaProvider` 统一缓存位置路径与分类元数据
- 排序新增 **「紧急优先」**（`AppConstants.sortOptions` 首项）

#### 4. 卡片布局 `ItemCardLayout`

- `reasonFirst`：名称 → 理由贴纸（大）→ 位置·数量
- `compact`：空间网格用小卡片
- `classic`：保留原双层贴纸（搜索页等复用）

#### 5. UI 结构

- `CartoonTabBar` 四 Tab + `TabBarView`
- 搜索栏全局；状态/分类 Chip 仅「全部」Tab 显示
- `ItemListSectionHeader` 用于空间/分类分组标题

### 改动文件

- `lib/core/models/item_list_view_tab.dart`（新）
- `lib/core/utils/item_list_reason_helper.dart`（新）
- `lib/presentation/items/providers/item_list_providers.dart`（新）
- `lib/presentation/items/widgets/item_list_section_header.dart`（新）
- `lib/presentation/items/item_list_page.dart`
- `lib/presentation/items/widgets/item_card.dart`
- `lib/core/constants/app_constants.dart`

### 影响范围

- 物品 Tab 列表交互与信息层次
- 搜索页 `ItemCard` 默认 `classic` 不受影响

## 提测开发文档

### 测试点

1. 物品页顶部四 Tab 可切换，默认「要处理」
2. **要处理**：仅显示快过期/库存不足等；卡片理由行醒目；空态「一切安好」
3. **按空间**：按房间分组，组内 3 列网格；点击进详情
4. **按分类**：按分类分组列表，带分组标题与件数
5. **全部**：理由标签 + 状态 Chip + 筛选/排序（含紧急优先）
6. 搜索在四 Tab 均生效
7. 扫码、FAB 添加、下拉刷新正常

### 验证

```powershell
cd HomeWareClient
flutter run
# 进入「物品」Tab，切换四个视图，录入快过期物品验证「要处理」
```

### 后续（阶段 2）

- 卡片左滑快捷操作（用完 / 加购物单）
- 空间 Tab 横向房间导航
- 理由进度条可视化

### 2026-06-25 补充：抖音式网格磁贴

- **问题**：按空间 3 列小卡片视觉过小，图片/信息看不清
- **方案**：`ItemCardLayout.grid` — 2 列 portrait 磁贴
  - 有图：`BoxFit.contain` 居中完整显示，高度按图片比例自适应（96~280px）
  - 无图：马卡龙渐变「文本海报」（大 emoji + 名称 + 品牌）
- **布局**：`ItemGridMasonry` 双列瀑布流，卡片高度随内容变化（替代固定 `childAspectRatio`）
- **范围**：按空间 / 按分类 Tab 均使用 grid 布局
- **描边修复**：`AppSurface` 默认 `Clip.none`；网格卡片内缩 `borderWidth` + 内层 `ClipRRect`，避免白底裁切彩色描边

### 2026-06-25 补充：网格图片 fitCenter + 高度自适应

- **诉求**：图片应完整居中显示（不裁剪），整卡高度随图片比例变化
- **实现**：
  - `_GridAdaptiveImage`：预读宽高比 → 固定 `SizedBox` 高度（加载前 1:1 占位），ListView 可稳定布局
  - `BoxFit.contain` 完整显示；宽高比限制在 0.55~1.5，避免极端卡片
  - 移除 `cacheHeight`（避免解码阶段纵向压扁）
  - `ItemGridMasonry` 双列瀑布流
- **测试**：按空间/按分类 Tab，对比横图/竖图/无图卡片高度差异；确认图片不变形、描边仍完整

### 2026-06-25 补充：ListView 布局崩溃修复

- **现象**：按空间 Tab 报 `RenderSliverPadding` / `geometry: null`，ListView 白屏
- **原因**：网格图片 `height: null` 依赖 intrinsic 高度，图片未加载前高度为 0，Sliver 无法完成 layout
- **修复**：恢复宽高比预读 + 固定 `SizedBox` 高度（加载前 1:1 占位），保留 `BoxFit.contain` 与无 `cacheHeight`

### 2026-06-25 补充：列表分页加载

详见 [`20260625_item_list_pagination.md`](20260625_item_list_pagination.md)

- 列表 Tab：首批 20 条 + 滚动加载更多
- 网格 Tab：每组首批 12 条 + 「加载更多」按钮
- 集中 `itemListDataProvider`，避免重复同步

### 2026-06-25 补充：物品页添加按钮恢复

- **问题**：滚动后 FAB 切换为「回到顶部」，添加入口消失；且 FAB 可能被底部导航遮挡
- **修复**：
  - FAB 固定为「添加物品」，不再与回到顶部互斥
  - 滚动后在 AppBar 显示回到顶部按钮
  - `CartoonMainTabFabLocation` 抬高 FAB，避开 `CartoonBottomNav`
  - 列表底部增加 FAB 留白
