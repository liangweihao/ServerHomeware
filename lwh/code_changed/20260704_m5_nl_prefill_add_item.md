# M5 录入减负 — 规则 NL 预填入库

**日期**：2026-07-04  
**状态**：已完成  
**里程碑**：Phase A M5 — 一句话进向导

---

## 一、技术开发说明

### 目标

用户用自然语言描述要入库的物品，规则引擎解析后预填分步向导，减少手工录入字段。

### 实现方案

1. **`AddItemNlParser`** — 纯规则解析名称 / 位置 / 数量 / 单位 / 过期日
2. **`applyAddItemNlPrefill`** — 写入 `ItemFormController`，匹配 DB 位置，建议向导起始步
3. **`ItemAddNlPrefillStorage`** — 跨路由单次消费暂存
4. **入口**：
   - 录入方式页「说话添物品」Bottom Sheet
   - 问管管识别 `addItem` 意图 →「去确认入库」按钮
5. **顺带修复** `AssistantParser`「牛奶在哪」误解析为「在哪」

### 支持语句示例

| 输入 | 预填 |
|------|------|
| 帮我添加牛奶在冰箱 | 名称、位置 |
| 入库2瓶酸奶放厨房 | 名称、2瓶、位置 |
| 记一笔创可贴 | 名称 |
| 牛奶放冰箱 | 名称、位置（无添加前缀） |
| 添加牛奶过期2026-12-01 | 名称、过期日 |

### 向导跳转规则

- 名称 + 分类 + 位置 → 从「位置」步开始（前几步标记已完成）
- 仅名称 + 自动分类 → 从「信息」步开始
- 含过期日且已有位置 → 从「时效」步确认

### 改动文件

| 路径 | 变更 |
|------|------|
| `core/assistant/add_item_nl_parser.dart` | 新增 |
| `core/assistant/assistant_models.dart` | `addItem` 意图 + 回复 action |
| `core/assistant/assistant_parser.dart` | 入库优先 + 修复在哪 |
| `core/assistant/assistant_executor.dart` | 处理 addItem |
| `core/assistant/guanguan_copy.dart` | 入库话术 |
| `presentation/items/add_item_nl_applier.dart` | 新增 |
| `presentation/items/item_add_nl_prefill_storage.dart` | 新增 |
| `presentation/items/widgets/add_item_nl_sheet.dart` | 新增 |
| `presentation/items/add_item_page.dart` | `nlPrefill` 参数 |
| `presentation/items/add_item_method_page.dart` | 说话添物品入口 |
| `presentation/assistant/assistant_chat_page.dart` | 确认入库按钮 |
| `core/router/app_router.dart` | `nlPrefill=1` query |
| `test/core/assistant/add_item_nl_parser_test.dart` | 新增 |

### 影响范围

- 客户端离线可用，无 LLM / 后端依赖
- 写操作仍经向导人工确认后保存（与 Phase 1 问管家边界一致）

---

## 二、提测说明

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 录入方式 → 说话添物品 → 示例 Chip | 跳转向导，名称/位置已填 |
| T2 | 问管管「添加牛奶在冰箱」 | 回复 +「去确认入库」按钮 |
| T3 | 预填后进向导 | 顶部 hint 显示已预填字段 |
| T4 | 位置不存在于 DB | 名称预填，位置留空，提示还需确认 |
| T5 | 「牛奶在哪」 | 仍为查询，不是入库 |
| T6 | 保存入库 | 与手动向导一致走 API + 本地 |
| T7 | 单测 | `add_item_nl_parser_test` 全绿 |

### 验证命令

```powershell
cd HomeWareClient
C:\flutter\bin\flutter.bat test test/core/assistant/add_item_nl_parser_test.dart test/core/assistant/assistant_parser_test.dart
```

---

## 三、后续

- Phase A Gate 验证后可启动 **管管 P1 今日面板**
- OCR 拍照识别仍为独立项（见归档 OCR 决策文档）
