# HomeStock AI Mode — Phase AI-1：基础对话框架

## 概述

在现有 HomeStock 服务端基础上，增加 AI 对话交互能力。
用户通过自然语言（语音或文字）与系统交互，AI 理解意图后执行操作并返回结构化结果。

## 技术选型补充

在现有 FastAPI 服务基础上增加：
- 大模型：OpenAI GPT-4 API（或通义千问/文心一言，通过统一接口封装）
- 语音识别：讯飞实时语音识别 WebSocket API
- 语音合成（TTS）：讯飞语音合成（可选）
- 会话管理：Redis 存储对话上下文

## 本阶段目标

实现基础的文字对话接口：用户发送文本 → AI理解意图 → 返回结构化响应。
暂不接入语音，先跑通文字链路。

---

## 任务1：AI 模块目录结构

在 app/ 下新增：

```
app/
├── ai/
│   ├── __init__.py
│   ├── intent_engine.py      # 意图识别引擎（核心）
│   ├── entity_extractor.py   # 实体提取
│   ├── context_manager.py    # 上下文管理
│   ├── action_executor.py    # 动作执行器
│   ├── response_builder.py   # 响应构建器
│   ├── prompts/              # Prompt 模板
│   │   ├── __init__.py
│   │   ├── system_prompt.py  # 系统提示词
│   │   └── few_shots.py      # 少样本示例
│   └── actions/              # 具体动作实现
│       ├── __init__.py
│       ├── add_item_action.py
│       ├── query_item_action.py
│       ├── record_usage_action.py
│       ├── move_item_action.py
│       ├── query_alerts_action.py
│       ├── statistics_action.py
│       └── shopping_action.py
```

---

## 任务2：对话 API 接口

**POST /api/v1/chat/message**

请求：
```json
{
  "session_id": "可选，无则创建新会话",
  "message": "用户输入的文字",
  "context": {
    "current_screen": "home",
    "last_item_id": null
  }
}
```

响应：
```json
{
  "session_id": "abc123",
  "reply": {
    "text": "自然语言回复文本",
    "tts_text": "语音播报文本",
    "emotion": "positive/neutral/warning"
  },
  "action": {
    "type": "add_item/query/usage/...",
    "status": "success/failed/need_more_info",
    "result": { ... }
  },
  "ui": {
    "type": "confirm_card/item_card/item_list/chart/form/choice/text",
    "data": { ... },
    "actions": [
      {"label": "按钮文字", "action_type": "动作类型", "params": {...}}
    ]
  },
  "suggestions": ["建议回复1", "建议回复2", "建议回复3"],
  "follow_up": null 或 "追问文本"
}
```

**POST /api/v1/chat/action**

说明：用户点击 UI 卡片上的操作按钮时调用
请求：
```json
{
  "session_id": "abc123",
  "action_type": "set_expiry",
  "params": {"item_id": 78, "expiry_date": "2024-07-15"}
}
```
响应：同上结构

**GET /api/v1/chat/sessions/{session_id}/history**

说明：获取对话历史
响应：消息列表

**DELETE /api/v1/chat/sessions/{session_id}**

说明：清除会话（重新开始）

---

## 任务3：意图识别引擎（intent_engine.py）

核心流程：
1. 接收用户文本
2. 加载上下文（之前对话记录、上一个操作的物品等）
3. 构造 Prompt（system_prompt + context + user_message）
4. 调用大模型 API
5. 解析大模型返回的 JSON
6. 返回结构化的 Intent + Entities

### 大模型调用封装

创建 LLMClient 类：
- 支持多个后端（OpenAI / 通义千问 / 文心一言）
- 通过配置切换
- 统一接口：chat(messages: list) → str
- 超时处理：5秒超时
- 重试机制：失败重试2次
- 降级策略：大模型挂了 → 尝试规则匹配

### System Prompt

```python
SYSTEM_PROMPT = """
你是 HomeStock 家庭物品管理助手。用户会用自然语言告诉你关于家庭物品的事情。

你的职责：
1. 理解用户的意图
2. 从用户话语中提取关键信息
3. 判断信息是否足够执行操作
4. 用友好自然的语言回复

## 可识别的意图

- add_item: 用户要添加/入库新物品
- query_item: 查询某物品的信息
- query_location: 查找物品位置
- record_usage: 记录使用/消耗了某物品
- mark_finished: 标记物品用完
- discard_item: 丢弃物品
- move_item: 移动物品到新位置
- update_item: 修改物品信息
- query_expiring: 查询即将过期的物品
- query_low_stock: 查询库存不足的物品
- generate_shopping: 生成/查看购物清单
- query_statistics: 查询消费统计
- set_reminder: 设置提醒
- general_chat: 闲聊或无法归类

## 当前家庭已有位置
{locations}

## 当前家庭已有分类
{categories}

## 上下文
{context}

## 输出要求

严格按以下 JSON 格式输出：
{
  "intent": "意图名称",
  "confidence": 0.0到1.0的浮点数,
  "entities": {
    "item_name": null或字符串,
    "brand": null或字符串,
    "quantity": null或数字,
    "unit": null或字符串,
    "location": null或字符串,
    "price": null或数字,
    "date": null或"YYYY-MM-DD"格式,
    "expiry_date": null或"YYYY-MM-DD"格式,
    "shelf_life": null或字符串如"7天""一个月",
    "channel": null或字符串,
    "person": null或字符串,
    "time_range": null或字符串如"这个月""最近一周"
  },
  "is_complete": true或false,
  "missing_fields": [],
  "reply_text": "自然语言回复",
  "follow_up_question": null或追问字符串
}

## 规则
- 如果意图是 add_item，item_name 是必须的，quantity 尽量提取（没说则默认1）
- 如果意图是 query_location，item_name 是必须的
- 如果意图是 record_usage，item_name 和 quantity 是必须的
- 中文数字要转为阿拉伯数字
- 日期模糊表述要转为具体日期
- 位置要匹配到已有位置列表中的最接近项
- 如果信息不完整，is_complete=false，并在 follow_up_question 中给出自然的追问
- 回复要简洁友好，像朋友对话
"""
```

---

## 任务4：上下文管理（context_manager.py）

### 会话存储（Redis）

```
Key: chat:session:{session_id}
Value: JSON
TTL: 30分钟（无活动自动过期）

结构：
{
  "user_id": 1,
  "family_id": 1,
  "messages": [
    {"role": "user", "content": "...", "timestamp": "..."},
    {"role": "assistant", "content": "...", "timestamp": "..."}
  ],
  "context": {
    "last_item_id": 78,
    "last_intent": "add_item",
    "awaiting_slot": "location",
    "pending_item": {暂存的未完成物品数据}
  }
}
```

### 上下文功能

- 保留最近10轮对话（避免超出token限制）
- 记录最近操作的物品ID（支持"它""那个"等指代）
- 记录"等待补充"状态（追问后等待用户回答）
- 会话超时后自动清除

---

## 任务5：动作执行器（action_executor.py）

根据 intent 路由到对应 Action：

```python
class ActionExecutor:
    def execute(self, intent, entities, context, family_id, user_id):
        action_map = {
            "add_item": AddItemAction,
            "query_item": QueryItemAction,
            "query_location": QueryLocationAction,
            "record_usage": RecordUsageAction,
            "move_item": MoveItemAction,
            "query_expiring": QueryExpiringAction,
            "query_low_stock": QueryLowStockAction,
            "generate_shopping": ShoppingAction,
            "query_statistics": StatisticsAction,
        }
        action_class = action_map.get(intent)
        if action_class:
            return action_class(context).execute(entities, family_id, user_id)
        else:
            return GeneralChatAction().execute(entities)
```

### 各 Action 职责

**AddItemAction：**
- 从 entities 中取出信息
- 如果 is_complete=False：返回追问响应
- 如果 is_complete=True：调用 item_service.create_item()
- 构建确认卡片 UI

**QueryLocationAction：**
- 从 entities 取 item_name
- 搜索数据库匹配物品
- 如果找到唯一匹配：返回位置信息
- 如果多个匹配：返回选择列表
- 如果没找到：返回未找到提示

**RecordUsageAction：**
- 从 entities 取 item_name + quantity
- 查找物品 → 更新数量 → 记录usage
- 返回确认卡片（含剩余量）

---

## 任务6：响应构建器（response_builder.py）

负责将 Action 的执行结果 + AI 的回复文本 组装成最终响应格式：

```python
class ResponseBuilder:
    def build(self, intent_result, action_result) -> ChatResponse:
        return {
            "reply": self._build_reply(intent_result, action_result),
            "action": self._build_action_info(action_result),
            "ui": self._build_ui(action_result),
            "suggestions": self._build_suggestions(intent_result),
            "follow_up": intent_result.get("follow_up_question")
        }
    
    def _build_ui(self, action_result):
        """根据 action 结果决定显示什么 UI"""
        if action_result.type == "item_created":
            return {"type": "confirm_card", "data": ...}
        elif action_result.type == "item_found":
            return {"type": "item_card", "data": ...}
        elif action_result.type == "item_list":
            return {"type": "item_list", "data": ...}
```

---

## 验收标准

1. ✅ POST /chat/message 接口可正常接收文本并返回结构化响应
2. ✅ "买了3盒牛奶" → 正确识别为 add_item，提取 item_name=牛奶 quantity=3
3. ✅ "创可贴在哪" → 正确识别为 query_location，返回位置信息
4. ✅ "用了一盒鸡蛋" → 正确识别为 record_usage，更新数据库
5. ✅ 信息不完整时正确追问（"买了牛奶" → "买了几盒？"）
6. ✅ 上下文保持：追问后用户回答数量，能关联到之前的物品
7. ✅ 会话历史可查询
8. ✅ 大模型超时/失败有降级处理
9. ✅ 响应时间 < 3秒（含大模型调用）