# 问管管查不到本地物品 + 回复日志

## 问题

用户问「金针菇在哪里」，App 物品列表里有，但管管回复没有。

### 根因

- LLM Function Calling 只查 **服务端 PostgreSQL/SQLite**
- 实测服务端 `items` 表 **0 条**（物品仅在手机本地 Drift）
- 问管管直连 LLM 后不再走本地 Drift 查询

## 方案

每次 `/assistant/chat` 请求附带 **本地库存快照** `local_items`：

```json
{
  "message": "金针菇在哪里",
  "local_items": [
    {"name": "金针菇", "quantity": 2, "unit": "盒", "location": "冰箱/蔬菜层"}
  ]
}
```

服务端工具 `query_item_stock` / `check_ingredients_availability`：

1. 先查服务端 DB  
2. 未命中 → 在 `local_items` 中模糊匹配（`keyword in name`）

## 改动点

| 文件 | 改动 |
|---|---|
| `assistant_local_inventory.dart` | **新增** 从 Drift 构建快照 |
| `assistant_executor.dart` | 发送前附带 local_items |
| `llm_assistant_service.dart` | 打印完整回复内容 |
| `assistant_chat_page.dart` | 打印管管回复 |
| `llm_service.py` | `_search_local_items` 兜底 + 回复日志 |
| `assistant.py` | 接收 local_items + 回复日志 |

## 提测

| 场景 | 预期 |
|---|---|
| 服务端无物品、本地有金针菇 | 回复位置与数量 |
| 日志 | Flutter/服务端均打印完整回复 |
| 服务端已有同物品 | 优先服务端结果 |

### 日志示例

```
[LlmAssistantService] INFO: 回复内容 >>> 金针菇在冰箱...
[LlmService] INFO: 服务端未命中，本地快照命中 keyword=金针菇 count=1
```
