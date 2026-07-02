# AI 对话助手 Phase 1 实现

**日期**：2026-07-02  
**状态**：已实现，待真机验收  
**关联方案**：[`20260702_ai_assistant_mvp_plan.md`](./20260702_ai_assistant_mvp_plan.md)

---

## 一、实现方案

Phase 1 采用 **端侧规则解析 + 本地 Drift 查询**，不调用云端 LLM，可离线使用。

### 架构

```
用户输入 → AssistantParser（关键词/正则）
         → AssistantExecutor（Drift + 现有筛选逻辑）
         → AssistantChatPage（气泡 + 物品结果列表）
```

### 支持意图

| 意图 | 示例 | 数据来源 |
|------|------|----------|
| `querySpaceItems` | 厨房有什么 | 空间树 + 使用中物品 |
| `queryItemLocation` | 牛奶在哪 / 还有牛奶吗 | items + location 路径 |
| `queryExpiring` | 什么快过期 | 临期/过期逻辑 |
| `queryLowStock` | 库存不足 / 快没了 | safety_stock |
| `queryPending` | 有什么要处理 | 临期+低库存汇总 |

不支持入库/记消耗，会引导用户使用「+」或物品详情。

---

## 二、改动点

### 新增文件

| 路径 | 说明 |
|------|------|
| `lib/core/assistant/assistant_models.dart` | 意图、解析结果、消息模型 |
| `lib/core/assistant/assistant_parser.dart` | 规则解析 |
| `lib/core/assistant/assistant_executor.dart` | 本地查询执行 |
| `lib/presentation/assistant/assistant_chat_page.dart` | 会话页「问管家」 |
| `lib/presentation/assistant/widgets/assistant_message_bubble.dart` | 消息气泡 |
| `lib/presentation/assistant/widgets/assistant_item_result_list.dart` | 结果列表，可跳转详情 |
| `test/core/assistant/assistant_parser_test.dart` | 解析器单元测试 |

### 修改文件

| 路径 | 说明 |
|------|------|
| `lib/core/router/app_router.dart` | 新增路由 `/assistant` |
| `lib/presentation/home/widgets/home_top_bar.dart` | 首页顶栏搜索与「+」之间增加「问管家」圆形入口 |

### 入口

- **首页顶栏**：搜索框右侧、添加入口左侧，`smart_toy_outlined` 图标 → `context.push('/assistant')`

---

## 三、影响范围

- 仅客户端新增模块与首页顶栏布局微调
- 无服务端/API/数据库 schema 变更
- 与现有 4 Tab 导航并存，独立全屏页

---

## 四、提测说明

### 测试点

1. 首页顶栏可见「问管家」图标，点击进入会话页
2. 欢迎语与建议 Chip 正常展示
3. 「厨房有什么」→ 返回该空间物品列表（无数据时友好提示）
4. 「牛奶在哪」→ 返回位置路径或匹配列表
5. 「什么快过期」「库存不足」「有什么要处理」→ 与提醒/列表逻辑一致
6. 结果项点击可进入 `/items/:id`
7. 空输入、无法识别意图时有引导文案

### 验证方式

```powershell
cd HomeWareClient
flutter analyze
flutter test test/core/assistant/assistant_parser_test.dart
.\scripts\run_dev.ps1
```

### 注意事项

- 需本地已有物品/空间数据才有有意义回复
- Phase 1 无会话持久化，退出页面后消息清空
- Phase 2 再考虑服务端 LLM 与自然语言增强

---

## 五、后续（Phase 2，未做）

- 服务端 `POST /api/v1/chat` + Redis 会话
- 搜索页 idle 快捷问题 Chip
- 个人中心「智能问答」宫格入口（可选）
