# 问管管对话历史迁服务端（方案 B）

## 技术开发文档

### 背景

本地 Drift 存储在卸载 App 后丢失。改为 **服务端按 family_id + user_id 持久化**，重装 / 换设备登录同一账号可恢复。

### 改动点

#### 后端

| 文件 | 改动 |
|---|---|
| `app/models/assistant_chat_message.py` | **新增** 对话消息表模型 |
| `app/repositories/assistant_chat_repo.py` | **新增** 增删查裁剪 |
| `app/api/v1/assistant.py` | `GET /history`、`DELETE /history`；`/chat` 自动读写 DB |
| `alembic/versions/0011_add_assistant_chat_messages.py` | **新增** 迁移 |

#### Flutter

| 文件 | 改动 |
|---|---|
| `assistant_chat_storage.dart` | 改为调用 `/assistant/history`、`DELETE /history` |
| `assistant_executor.dart` | 移除 Drift 依赖；不再传 history |
| `llm_assistant_service.dart` | 仅发 message；购物清单提示由服务端拼接 |
| `assistant_chat_page.dart` | 从服务端加载/清空 |

### API

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/api/v1/assistant/history?limit=50` | 加载历史 |
| DELETE | `/api/v1/assistant/history` | 清空历史 |
| POST | `/api/v1/assistant/chat` | 对话（自动保存 user + assistant） |

### 数据归属

- `family_id` + `user_id` 隔离
- 每用户最多保留 **100** 条，自动裁剪
- LLM 上下文优先从 DB 最近 12 条加载

### 本地 Drift `assistant_messages` 表

- 保留 schema v7 但 **不再写入**
- 后续版本可移除

---

## 提测开发文档

### 部署

```bash
cd HomeWareServer
PYTHONPATH=. alembic upgrade head
# 重启后端
```

### 测试点

| 场景 | 预期 |
|---|---|
| 对话后退出再进 | 历史从服务端加载 |
| 卸载重装 App（同账号登录） | 历史仍在 |
| 换设备同账号 | 历史同步 |
| 清空对话 | 服务端删除，各端再进为空 |
| 未登录 | 401，无法加载 |

### 验证 SQL

```sql
SELECT id, role, substr(content,1,40), created_at
FROM assistant_chat_messages
ORDER BY id DESC LIMIT 10;
```
