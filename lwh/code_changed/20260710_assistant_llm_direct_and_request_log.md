# 助手直连 LLM + 请求记录

## 技术开发文档

### 实现方案

按产品决策：**暂不走端侧规则/意图缓存，所有助手对话统一走 LLM**。

- 端侧 `AssistantExecutor` 简化为 LLM 薄封装，保留多轮 `history`
- 服务端在 `activity_logs` 记录每次对话（message、reply 摘要、shopping_added、history_turns）
- 后续基于记录数据做「意图缓存」命中后再考虑恢复本地快路径

### 改动点

#### Flutter

| 文件 | 改动 |
|---|---|
| `lib/core/assistant/assistant_executor.dart` | 移除规则分流 switch，统一 `_llm.chat()` |
| `lib/presentation/assistant/assistant_chat_page.dart` | 会话级复用 `AssistantExecutor`（修复多轮历史丢失）；更新文案 |

#### 后端

| 文件 | 改动 |
|---|---|
| `app/models/activity_log.py` | 新增 `ACTION_ASSISTANT_CHAT` |
| `app/api/v1/assistant.py` | 对话完成后写入 `activity_logs` |
| `app/services/activity_service.py` | 活动文案映射 |

### 影响范围

- `AssistantParser` 及单测保留，供后续意图缓存开发参考，当前运行时不再调用
- 助手页需联网；离线不再走本地 Drift 查询

### 附带修复

- 原每次 `_send` 新建 `AssistantExecutor`，导致 `_history` 始终为空，多轮上下文无效

---

## 提测开发文档

### 测试点

| 场景 | 预期 |
|---|---|
| 任意输入（创可贴/我手粗糙/想吃红烧肉） | 日志 `直连 LLM`，均请求 `/assistant/chat` |
| 连续两轮对话 | 第 2 轮携带 history，LLM 能理解上文 |
| 服务端记录 | `activity_logs` 新增 `action=assistant_chat` |
| 记录失败 | 不影响对话返回（WARN 日志） |

### 验证方式

1. Flutter 助手页输入任意问题，观察日志无 `queryItemLocation` 等本地 intent
2. 数据库查 `activity_logs`：`SELECT * FROM activity_logs WHERE action='assistant_chat' ORDER BY id DESC LIMIT 5`
3. 连续问「想吃红烧肉」→「把缺的加进购物清单」，确认第二轮理解上下文

### 后续（意图缓存）

- 分析 `activity_logs.detail.message` 聚类高频意图
- 命中缓存时再走 `AssistantParser` 本地快路径，未命中继续 LLM
