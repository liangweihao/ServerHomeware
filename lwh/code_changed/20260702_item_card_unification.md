# ItemCard 统一专项

> 日期：2026-07-02

---

## 技术开发文档

### 背景

首页 `HomeItemCard` 与列表 `ItemCard` 视觉与数据模型分离，工具风网格与首页 Feed 卡不一致，维护成本高。

### 实现方案

1. **`ItemCardFeedData`** — 统一 Feed 展示数据
   - `fromHomeSection(HomeSectionItem)` — 首页/API 分区
   - `fromItem(Item, ...)` — 列表网格

2. **`ItemCardLayout.feed`** + **`ItemCard.feed()`** 命名构造
   - 上图下文：封面 → 名称 → 位置 → TagChip
   - 工具风 / 卡通风双分支

3. **工具风 `grid` 布局** 复用 `_buildUtilityFeedBody`，与首页卡片一致

4. **删除** `home_item_card.dart`，调用方迁移至 `ItemCard.feed`

### 改动文件

| 文件 | 说明 |
|------|------|
| `item_card_feed_data.dart` | 新建，Feed 数据模型 |
| `item_card.dart` | feed 布局 + grid 统一 + `ItemCard.feed` |
| `home_two_row_scroll_grid.dart` | 使用 `ItemCard.feed` |
| `search_recommend_sections.dart` | 同上 |
| `home_section_list_page.dart` | 同上 |
| `home_item_card.dart` | **删除** |
| `test/.../item_card_feed_data_test.dart` | 单元测试 |

### 影响范围

- 首页四分区横滑、搜索推荐、分区「查看全部」网格
- 物品列表网格视图（工具风主题下视觉与首页对齐）

---

## 提测开发文档

### 测试点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 首页四分区横滑 | 竖卡：图+名+位置+状态标签 |
| T2 | 搜索页推荐分区 | 与首页卡片一致 |
| T3 | 首页「查看全部」网格 | 2 列 Feed 卡 |
| T4 | 物品列表网格视图 | 工具风下与首页 Feed 一致 |
| T5 | 切换卡通主题 | 首页 Feed 卡通风描边正常 |
| T6 | 点击卡片 | 跳转物品详情 |

### 验证方式

- 目视对比首页与物品列表网格
- `flutter test test/presentation/items/item_card_feed_data_test.dart`

### 注意事项

- 列表 `classic` / `reasonFirst` 横条布局未改动
- `WarmSearchResultTile` 搜索结果为独立组件，未纳入本次
