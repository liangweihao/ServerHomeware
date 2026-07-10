# 问管管 — 查询命中物品可点击跳转详情

## 需求

用户问「羊肉在哪里」时，管管回复中提到的具体物品应支持点击，跳转到 `/items/{id}` 物品详情页。

## 实现方案

### 数据流

```
工具命中物品（query_item_stock 等）
  → LlmService 收集 referenced_items（含 local_id / item_id）
  → /assistant/chat 响应 items[]
  → 客户端 AssistantItemResolver 解析 Drift 本地 id
  → AssistantItemResultList 展示可点击卡片
  → 历史 meta_json 持久化 items，重装后可恢复
```

### 服务端

| 文件 | 改动 |
|------|------|
| `llm_service.py` | 工具结果追踪 `_track_tool_items`；快照含 `local_id`/`server_item_id`；响应 `items` |
| `assistant.py` | `AssistantItemCard`；`meta_json.items` 持久化 |

### 客户端

| 文件 | 改动 |
|------|------|
| `assistant_local_inventory.dart` | 快照增加 `local_id`、`server_item_id` |
| `assistant_item_resolver.dart` | API 解析 + Drift id 补全 |
| `llm_assistant_service.dart` | 解析 `data.items` |
| `assistant_executor.dart` | 发送后 resolve 导航 id |
| `assistant_chat_page.dart` | 加载历史时 resolve items |
| `assistant_item_result_list.dart` | 已有，点击 `context.push('/items/${item.itemId}')` |

## 提测要点

1. 重启后端 + 热重载 App
2. 问「羊肉在哪里」或「金针菇在哪」
3. 期望：气泡下方出现物品卡片（名称 + 位置·数量），点击跳转详情
4. 日志：
   - 服务端 `[AssistantRouter] INFO: ... items=['十斤羊肉']`
   - 客户端 `[AssistantItemResolver] INFO: 物品可跳转 name=... navId=...`
5. 退出问管管再进入，历史消息下方卡片仍可点击

## 注意事项

- 仅工具实际命中的物品会出现卡片；纯闲聊无库存查询时不展示
- 若本地 Drift 找不到对应物品（已删除），卡片不展示并打 WARN 日志
