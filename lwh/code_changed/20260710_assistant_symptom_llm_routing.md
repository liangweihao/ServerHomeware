# 助手症状诉求路由 LLM 修复

## 技术开发文档

### 问题

用户输入「我手有点粗糙」时，日志显示：

```
intent=AssistantIntentType.queryItemLocation item=我手有点粗糙
```

未触发 LLM（无「升级到 LLM」日志）。

### 根因

`AssistantParser` 采用**规则优先 + LLM 兜底**：

1. `_extractItemName()` 未匹配（无「在哪」「有没有」等句式）
2. `_llmIntentPrefixes` 未包含皮肤护理类关键词
3. **短词兜底**（≤12 字且不含「吗/？」）将整句当作物品名 → `queryItemLocation`

### 改动点

| 文件 | 改动 |
|---|---|
| `lib/core/assistant/assistant_parser.dart` | 新增 `_looksLikeSymptomOrNeed()`、`_looksLikeItemQuery()`；扩展 `_llmIntentPrefixes`；短词兜底前先判断症状/护理诉求 |
| `test/core/assistant/assistant_parser_test.dart` | 新增症状、短词物品、做饭三类用例 |

### 路由逻辑（修复后）

```
用户输入
  → 规则关键词（临期/低库存/…）
  → 空间/物品句式提取
  → _looksLikeSymptomOrNeed()  → unknown → LLM  ✅「我手有点粗糙」
  → 短词兜底（创可贴、牛奶）   → queryItemLocation（本地）
  → 其余                        → unknown → LLM
```

### 影响范围

- 仅影响端侧意图分类，不改变 LLM 接口与本地查询逻辑
- 「创可贴」等短物品名仍走本地零延迟查询

---

## 提测开发文档

### 测试点

| 输入 | 预期 intent | 预期行为 |
|---|---|---|
| 我手有点粗糙 | unknown | 日志「升级到 LLM」，推荐护手霜等 |
| 想吃红烧肉 | unknown | 走 LLM，查调料库存 |
| 创可贴 | queryItemLocation | 本地查库存，不请求 LLM |
| 牛奶在哪 | queryItemLocation | 本地查位置 |

### 验证方式

```bash
cd HomeWareClient
flutter test test/core/assistant/assistant_parser_test.dart
```

Flutter 端热重载后，助手页输入「我手有点粗糙」，日志应出现：

```
[AssistantExecutor] INFO: intent=AssistantIntentType.unknown ...
[AssistantExecutor] INFO: 升级到 LLM, history=...
```
