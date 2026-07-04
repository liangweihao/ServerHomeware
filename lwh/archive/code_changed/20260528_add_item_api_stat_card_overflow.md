# 添加物品对接 API + 首页统计卡片溢出修复

## 实现方案

### 添加物品 POST /api/v1/items
- 新增 `ItemService.createItem`，请求体字段对齐 `CreateItemRequest`（Phase 2 文档）
- `AddItemPage._saveItem`：先调服务端创建，成功后再写本地 SQLite（使用服务端返回的 `id`）
- 保存中禁用按钮，失败时 SnackBar 提示

### 首页 StatCard 溢出
- `Column` 设置 `mainAxisSize: min`，缩小间距与主数字字号
- 统计网格 `childAspectRatio` 1.3 → 1.38

## 改动点

| 文件 | 变更 |
|------|------|
| `item_service.dart` | 新增 |
| `add_item_page.dart` | 保存走 API + 本地缓存 |
| `stat_card.dart` | 布局防溢出 |
| `home_page.dart` | 调整网格宽高比 |

## 提测要点

1. 登录并加入家庭后添加物品，服务端应出现记录（`item_count` 增加）
2. 未登录或 token 失效：提示错误，不写入本地
3. 首页「需要关注」四宫格无黄黑条纹溢出
4. **注意**：分类/位置 ID 目前使用本地库 ID，若与服务端种子数据 ID 不一致，可能返回 4xx；后续需做分类/位置与服务端 ID 映射或同步
