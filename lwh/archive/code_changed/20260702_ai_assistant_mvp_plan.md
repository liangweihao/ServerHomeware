# AI 对话助手 MVP 方案（选项 A）

**日期**：2026-07-02  
**状态**：方案确认，待开发  
**关联**：[`doc/roadmap/ai-mode/Phase AI-1：基础对话框架.md`](../../doc/roadmap/ai-mode/Phase%20AI-1：基础对话框架.md)

---

## 一、为什么 App 里看不到 AI

| 现状 | 说明 |
|------|------|
| `doc/roadmap/ai-mode/` | **仅有规划文档**，未写代码 |
| 服务端 | 无 `app/ai/`，无 `POST /api/v1/chat` |
| 客户端 | 无会话页、无路由、无入口 |
| 「拍照识别」 | OCR **占位禁用**，与对话助手无关 |

用户选择 **A：对话助手**（问「厨房还有什么」→ 查库存）后，按本方案分阶段落地。

---

## 二、产品原则（结合 OCR 成本决策）

1. **Phase 1 不依赖云端大模型** — 规则 + 本地 Drift 查询，**零 API 费用、可离线**
2. **Phase 2 可选 LLM** — 配置 `OPENAI_API_KEY`（或通义等）后增强自然语言理解
3. **与 4 Tab 并存** — 助手为 **独立入口**，不替换现有导航（与 AI-2 未决方案一致）

---

## 三、Phase 1 — 端侧规则助手（推荐先做）

### 3.1 入口

| 位置 | 交互 |
|------|------|
| 首页顶栏 | 搜索框左侧增加 **「问管家」** 图标 → `/assistant` |
| 搜索页 idle | 快捷问题 Chip：「厨房有什么」「什么快过期」 |
| 个人中心宫格（可选） | 「智能问答」 |

### 3.2 支持意图（规则匹配，无需 LLM）

| 用户说法示例 | 意图 | 数据来源 |
|--------------|------|----------|
| 牛奶在哪 / 还有牛奶吗 | `query_location` | 本地 items + locations |
| 厨房有什么 / 卫生间还剩什么 | `query_space_items` | 按空间树查物品 |
| 什么快过期了 / 临期 | `query_expiring` | expiry + alerts 逻辑 |
| 什么快没了 / 库存不足 | `query_low_stock` | safety_stock |
| 有什么要处理 | `query_pending` | 过期+临期+低库存汇总 |
| 今天买了什么（Phase 1.1） | `query_recent_add` | created_at |

**不支持（Phase 1 明确引导）**：添加入库、记消耗 → 回复「请用 + 或物品详情操作」，避免半吊子写库。

### 3.3 客户端结构

```
lib/
├── core/assistant/
│   ├── assistant_intent.dart      # 意图枚举 + 实体
│   ├── assistant_parser.dart      # 规则/关键词解析
│   └── assistant_executor.dart    # 调 Drift / 现有 provider
└── presentation/assistant/
    ├── assistant_chat_page.dart   # 气泡会话 UI
    └── widgets/
        ├── assistant_message_bubble.dart
        └── assistant_item_cards.dart  # 结果用 ItemCard 迷你列表
```

### 3.4 会话 UI（MVP）

- 顶部：`家庭物品管家`
- 中间：用户/助手气泡；助手回复可带 **物品卡片列表**（点进详情）
- 底部：输入框 + 发送；上方 **建议问题** 横滑 Chip
- 无 session 持久化（Phase 1）；Phase 2 再加 Redis/本地历史

### 3.5 验收标准

1. 首页可见入口，进入会话页
2. 「厨房有什么」→ 列出该空间下使用中物品（≤20 条 + 查看更多）
3. 「牛奶在哪」→ 单条返回位置路径；多条返回选择列表
4. 「什么快过期」→ 与提醒 Tab 数据一致
5. 无网络时仍可用（读本地 Drift）
6. 响应 < 500ms（无 LLM 调用）

---

## 四、Phase 2 — 服务端 LLM（可选增强）

按 [`Phase AI-1`](../../doc/roadmap/ai-mode/Phase%20AI-1：基础对话框架.md) 实现：

| 模块 | 说明 |
|------|------|
| `POST /api/v1/chat/message` | 意图 JSON + 执行 |
| `app/ai/intent_engine.py` | LLM + **规则降级** |
| Redis 会话 | 30 分钟 TTL |
| 配置 | `.env` 中 `LLM_PROVIDER` / `OPENAI_API_KEY`，未配置则服务端也走规则 |

客户端：设置页增加「AI 助手（云端增强）」开关，默认关。

---

## 五、Phase 3 — 语音与写操作（后续）

- STT 语音输入（AI-2）
- 对话内「记消耗 / 添加入库」经确认卡片执行（AI-3）

---

## 六、开发排期建议

| 阶段 | 工作量 | 产出 |
|------|--------|------|
| **Phase 1** | 2–3 天 | 可见的「问管家」+ 5 类查询 |
| Phase 2 | 4–5 天 | 服务端 chat + LLM 可选 |
| Phase 3 | 按 Epic | 语音 + 写操作 |

---

## 七、提测要点（Phase 1）

1. 入口从首页进入会话页
2. 五类示例问题均返回合理结果
3. 空家庭 / 无匹配时的友好文案
4. 结果卡片跳转物品详情
5. 与「拍照识别」占位无冲突

---

## 八、待你确认

- [ ] **先做 Phase 1（端侧规则、零成本）** — 推荐
- [ ] 入口放 **首页顶栏** 还是 **个人中心宫格**
- [ ] Phase 2 是否接受 **可选 LLM API 费用**（不配 Key 则仍用规则）

确认后可开始编码。
