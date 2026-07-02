# 物品列表分页加载

## 技术开发文档

### 背景

物品数量增多时，原实现一次性 `getAllItems()` + 全量渲染卡片，导致首屏慢、滚动卡顿、网格 Tab 同组图片并发过多。

### 实现方案

#### 1. 集中数据源 `itemListDataProvider`

- 同步（`ItemSyncService.syncFromServer`）仅在数据源 Provider 刷新时执行一次
- `filteredItemsProvider` / `itemListSearchBaseProvider` 复用该数据，避免每个 Tab 重复同步 + 查库

#### 2. 列表 Tab 分页（要处理 / 全部）

- `actionItemsPaginatedProvider` / `allItemsPaginatedProvider`（`AsyncNotifier`）
- 首批 `listPageSize = 20`，滚动距底部 280px 自动 `loadMore()`
- 底部展示加载指示或「已显示 x/y」

#### 3. 网格 Tab 组内分页（按空间 / 按分类）

- `PaginatedGridSection`：每组首批 `gridPageSize = 12` 条
- 组内「加载更多 (12/45)」按钮手动展开
- 避免单组上百物品一次性 build + 预读图片

#### 4. 常量

- `lib/core/constants/item_list_constants.dart`

### 改动文件

- `lib/core/constants/item_list_constants.dart`（新）
- `lib/presentation/items/providers/item_list_providers.dart`
- `lib/presentation/items/providers/item_list_pagination.dart`（新）
- `lib/presentation/items/widgets/paginated_grid_section.dart`（新）
- `lib/presentation/items/item_list_page.dart`

### 说明

- 筛选/排序仍在内存完成（保证「紧急优先」等逻辑正确），分页仅控制 **UI 展示量**
- 下拉刷新 `invalidate` 数据源 + 分页 Provider，重置到首批

## 提测开发文档

### 测试点

1. **要处理 / 全部**：超过 20 条时首批只显示 20，滚到底自动加载下一批
2. 底部出现 loading 或「已显示 40/100」文案
3. **按空间 / 按分类**：单组超过 12 条时出现「加载更多」，点击后增量展示
4. 搜索 / 筛选 / 切换 Tab 后分页重置
5. 下拉刷新后从首批重新开始
6. 物品少时无多余「加载更多」按钮

### 验证

```powershell
cd HomeWareClient
flutter run
# 录入或同步 30+ 物品，分别在四个 Tab 验证
```

### 后续优化（可选）

- Drift SQL `LIMIT/OFFSET` 真分页（需将紧急度排序下推或预计算字段）
- 网格 Tab 滚动到底自动展开下一组（当前为组内按钮）
