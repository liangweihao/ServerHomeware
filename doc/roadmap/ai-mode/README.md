# AI 对话增强（规划中）

> **问管家 Phase 1 已上线**（2026-07-02）：本地规则引擎，5 类查询意图，详见 [core/business-flows.md](../../core/business-flows.md#6-问管家assistant-phase-1)。  
> 以下文档描述 **云端 LLM / 语音 / 写操作** 等增强能力，**尚未开发**。

---

## 已实现 vs 规划

| 能力 | 状态 | 说明 |
|------|------|------|
| 问管家查询（本地规则） | ✅ | `core/assistant/`，离线可用 |
| 问管家写操作 | ❌ | 引导到「+」或物品详情 |
| 云端 LLM 对话 | ❌ | 无 `/api/v1/chat` |
| 语音识别 STT | ❌ | |
| 管管 hello 序列帧 | 🟡 | 设计完成，部分落地 |

---

## 文档列表（原始规划，保留参考）

| 文件 | 内容 |
|------|------|
| [Phase AI-1：基础对话框架.md](Phase%20AI-1：基础对话框架.md) | 后端 chat API、意图引擎 |
| [Phase AI-2：语音接入 & Flutter对话UI.md](Phase%20AI-2：语音接入%20&%20Flutter对话UI.md) | STT、会话界面 |
| [Phase AI-3：智能增强 & 体验优化.md](Phase%20AI-3：智能增强%20&%20体验优化.md) | 模糊匹配、主动提醒 |

以上文件从原 `doc/AI驱动APP/` 迁入，保留原始规划细节。

---

## 与产品路线图的关系

AI 增强属于 [product/roadmap.md](../../product/roadmap.md) **阶段 3**。  
开发前需评审：LLM 增强是否与现有单页首页 UX 并存，或作为问管家模块升级。

**决策待定**：对话 UI 是否替代 Tab（已废弃 Tab 方案，现行为单页首页 + push）。
