# 大模型接入 — DeepSeek AI 助手

## 技术开发文档

### 实现方案

采用**规则优先 + LLM 兜底**策略：
- 端侧 `AssistantParser` 能识别的意图（查物品、查空间、临期、低库存等）直接本地处理，0 延迟、离线可用
- `unknown` 意图升级到服务端 LLM 接口，由 DeepSeek 处理复杂自然语言（"想吃红烧肉缺什么调料"、"手受伤了家里有没有创可贴"）

### 改动点

#### 后端

| 文件 | 改动 |
|---|---|
| `app/config.py` | 新增 `DEEPSEEK_API_KEY`、`DEEPSEEK_BASE_URL`、`DEEPSEEK_MODEL`、`DEEPSEEK_MAX_HISTORY_TURNS`、`DEEPSEEK_TIMEOUT_SECONDS` 配置项 |
| `app/services/llm_service.py` | **新增** — LLM 服务核心，封装 DeepSeek API 调用、Function Calling 执行循环（最多 3 轮）、4 个工具（查物品/查分类/批量检查库存/加购物清单） |
| `app/repositories/item_repo.py` | 新增 `search_by_name()`、`search_by_category_keyword()` 两个模糊搜索方法，供 LLM Function Calling 调用 |
| `app/api/v1/assistant.py` | **新增** — `POST /assistant/chat` 路由，支持多轮历史 |
| `app/api/v1/__init__.py` | 注册 `assistant_router` |
| `app/api/router.py` | 注册 `assistant_router` |
| `requirements.txt` | 新增 `httpx==0.27.0`（异步 HTTP 客户端，调用 DeepSeek） |
| `.env.example` | 新增 `DEEPSEEK_API_KEY` 等占位说明 |

#### Flutter 端

| 文件 | 改动 |
|---|---|
| `lib/core/services/llm_assistant_service.dart` | **新增** — 调用 `/assistant/chat`，封装历史传递和 shopping_added 提示文本 |
| `lib/core/assistant/assistant_executor.dart` | 新增 `_llm` 字段、`_history` 列表、`_handleWithLlm()`、`_appendHistory()`；`unknown` 意图从 `_helpReply()` 改为走 LLM |

### 影响范围

- 新增路由 `POST /api/v1/assistant/chat`，不影响现有路由
- `AssistantExecutor` 构造函数新增可选参数 `llm`，向后兼容
- 未配置 `DEEPSEEK_API_KEY` 时 LLM 服务优雅降级，返回提示文本

---

## 提测开发文档

### 依赖安装

```bash
cd HomeWareServer
pip install httpx==0.27.0
```

### Key 填写位置

编辑 `HomeWareServer/.env`（或 `.env.dev`）：

```
DEEPSEEK_API_KEY=sk-你的key
```

### 测试点

| 场景 | 输入示例 | 预期结果 |
|---|---|---|
| 规则路径不受影响 | "创可贴在哪" | 走本地查询，不请求 LLM |
| 做饭助手 | "想吃红烧肉" | LLM 调用工具查调料库存，返回有/缺清单 |
| 应急查找 | "手划破了" | LLM 返回急救物品列表及位置 |
| 加购物清单 | "把缺的加进购物清单" | `shopping_added` 非空，界面显示"已加入"提示 |
| 多轮对话 | 连续追问 | 第 2 轮携带 history，LLM 能理解上文 |
| 未配 Key | DEEPSEEK_API_KEY 为空 | 返回"AI 助手功能暂未开启"，不报错 |
| API 超时 | 模拟网络延迟 | 30s 超时后返回友好提示 |

### 验证方式

1. 后端启动后访问 `http://localhost:8000/docs`，找到 `/assistant/chat` 接口手动测试
2. Flutter 端打开助手页，输入"想吃红烧肉"观察是否走 LLM 路径（日志打印 `升级到 LLM`）
3. 检查购物清单页，确认自动加入的物品存在

### 注意事项

- `DEEPSEEK_API_KEY` 只写入 `.env` / `.env.dev`，不得提交到 git（`.gitignore` 已覆盖）
- LLM 单次最大 512 tokens，回复较长时会被截断，属正常
- `search_by_name` 使用 `ilike` 模糊匹配，SQLite 下 `ilike` 等同 `like`，不区分大小写
