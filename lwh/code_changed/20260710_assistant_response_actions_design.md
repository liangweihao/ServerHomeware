# 问管管 — 助手返回结构 & Action 设计（预览）

> 目的：让大模型回复不仅能「说话」，还能驱动客户端跳转、展示卡片、执行操作。  
> 状态：**设计预览**，尚未落地代码。

---

## 一、整体返回结构

### 当前（已实现）

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "text": "创可贴还有 5 个，在卫生间～",
    "shopping_added": [],
    "action": null
  }
}
```

`action` 为单个字符串，未定义枚举，客户端未消费。

### 建议（新版）

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "text": "创可贴还有 5 个，在卫生间～要记一笔消耗吗？",
    "shopping_added": [],
    "items": [],
    "suggestions": ["还有什么要处理的", "厨房有什么"],
    "actions": [
      {
        "type": "navigate",
        "label": "查看创可贴",
        "route": "/items/42",
        "payload": { "item_id": 42 }
      },
      {
        "type": "quick_consume",
        "label": "用掉 1 个",
        "payload": { "item_id": 42, "quantity": 1 }
      }
    ]
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `text` | string | 管管自然语言回复（必填） |
| `shopping_added` | string[] | 本轮自动加入购物清单的物品名 |
| `items` | ItemSummary[] | 结构化物品卡片（可选，减少纯文字） |
| `suggestions` | string[] | 下一轮建议追问 |
| `actions` | Action[] | **可点击操作按钮**（0～3 个为宜） |

---

## 二、Action 类型定义

```typescript
// 逻辑类型，便于前后端对齐
type ActionType =
  | "navigate"        // 跳转 App 内页面
  | "quick_consume"   // 快捷消耗（调已有消耗 API）
  | "add_shopping"    // 手动触发加购物清单（LLM 未自动加时）
  | "open_add_item"   // 打开添加入口（NL 预填）
  | "open_shopping"   // 打开购物清单页
  | "open_alerts";    // 打开提醒中心

interface AssistantAction {
  type: ActionType;
  label: string;           // 按钮文案，如「查看详情」「去添加」
  route?: string;          // navigate 时必填，go_router 路径
  payload?: Record<string, unknown>;  // 业务参数
  primary?: boolean;       // 是否主按钮（珊瑚填充），默认 false
}
```

---

## 三、场景示例（看效果）

### 场景 1：查单个物品 —「创可贴在哪」

```json
{
  "text": "创可贴还有 5 个，在卫生间药箱～",
  "shopping_added": [],
  "items": [
    {
      "item_id": 42,
      "name": "创可贴",
      "subtitle": "卫生间/药箱 · 剩余 5盒"
    }
  ],
  "suggestions": ["还有什么要处理的", "低库存有哪些"],
  "actions": [
    {
      "type": "navigate",
      "label": "查看创可贴",
      "route": "/items/42",
      "payload": { "item_id": 42 },
      "primary": true
    },
    {
      "type": "quick_consume",
      "label": "用掉 1 个",
      "payload": { "item_id": 42, "quantity": 1 }
    }
  ]
}
```

**客户端效果**：文字气泡 + 物品卡片 + 两个按钮（主色「查看」+ 次要「消耗」）

---

### 场景 2：做饭缺料 —「想吃红烧肉」

```json
{
  "text": "做红烧肉还缺五花肉、冰糖、生抽等 9 样。要把缺的加入购物清单吗？",
  "shopping_added": [],
  "items": [],
  "suggestions": ["把缺的加进购物清单", "只有五花肉能做吗"],
  "actions": [
    {
      "type": "add_shopping",
      "label": "加入购物清单",
      "payload": {
        "items": ["五花肉", "冰糖", "生抽", "老抽", "料酒", "姜", "葱", "八角", "桂皮"]
      },
      "primary": true
    },
    {
      "type": "open_shopping",
      "label": "查看购物清单",
      "route": "/shopping"
    }
  ]
}
```

**客户端效果**：追问式回复 + 主按钮一键加清单（若 LLM 已自动加则 `shopping_added` 非空，按钮可隐藏）

---

### 场景 3：已自动加购物清单

```json
{
  "text": "好的，已经把缺的调料都记进购物清单啦～",
  "shopping_added": ["五花肉", "冰糖", "生抽"],
  "items": [],
  "suggestions": ["还有什么要买的", "创可贴在哪"],
  "actions": [
    {
      "type": "open_shopping",
      "label": "去看看清单",
      "route": "/shopping",
      "primary": true
    }
  ]
}
```

---

### 场景 4：皮肤护理 —「我手有点粗糙」

```json
{
  "text": "家里有护手霜和凡士林，都在卫生间。建议先用护手霜～",
  "shopping_added": [],
  "items": [
    {
      "item_id": 88,
      "name": "护手霜",
      "subtitle": "卫生间 · 剩余 1支"
    },
    {
      "item_id": 91,
      "name": "凡士林",
      "subtitle": "卫生间 · 剩余 1罐"
    }
  ],
  "suggestions": ["护手霜在哪", "还有什么护肤品"],
  "actions": [
    {
      "type": "navigate",
      "label": "查看护手霜",
      "route": "/items/88",
      "payload": { "item_id": 88 },
      "primary": true
    }
  ]
}
```

---

### 场景 5：临期提醒 —「什么快过期了」

```json
{
  "text": "有 3 件快过期：牛奶、酸奶、面包。建议本周内处理哦～",
  "shopping_added": [],
  "items": [
    { "item_id": 10, "name": "牛奶", "subtitle": "冰箱 · 后天到期" },
    { "item_id": 11, "name": "酸奶", "subtitle": "冰箱 · 3天后到期" },
    { "item_id": 12, "name": "面包", "subtitle": "厨房 · 5天后到期" }
  ],
  "suggestions": ["低库存有哪些", "牛奶在哪"],
  "actions": [
    {
      "type": "open_alerts",
      "label": "打开提醒中心",
      "route": "/alerts",
      "primary": true
    },
    {
      "type": "navigate",
      "label": "查看牛奶",
      "route": "/items/10",
      "payload": { "item_id": 10 }
    }
  ]
}
```

---

### 场景 6：纯闲聊 / 无操作

```json
{
  "text": "好的，有需要再叫我～",
  "shopping_added": [],
  "items": [],
  "suggestions": ["厨房有什么", "有什么要处理的"],
  "actions": []
}
```

---

## 四、服务端如何产生 actions

**不由大模型直接拼 JSON**（容易幻觉），推荐：

```
LLM 调用工具
    ↓
服务端根据工具执行结果，用规则组装 actions
    ↓
LLM 只负责 text 自然语言
```

| 工具调用结果 | 自动附加 actions |
|-------------|-----------------|
| `query_item_stock` 找到 1 个 | `navigate` + 可选 `quick_consume` |
| `query_item_stock` 找到多个 | 仅 `items` 卡片，无 navigate |
| `check_ingredients` 有 missing | `add_shopping` + `open_shopping` |
| `add_to_shopping_list` 成功 | `open_shopping` |
| `query_items_by_category` | `items` 列表 + 首个 `navigate` |

```python
# 伪代码
def build_actions(tool_results: list) -> list[dict]:
    actions = []
    if single_item := tool_results.get("single_item"):
        actions.append({
            "type": "navigate",
            "label": f"查看{single_item.name}",
            "route": f"/items/{single_item.id}",
            "payload": {"item_id": single_item.id},
            "primary": True,
        })
    if missing := tool_results.get("missing_items"):
        actions.append({
            "type": "add_shopping",
            "label": "加入购物清单",
            "payload": {"items": missing},
            "primary": True,
        })
    return actions[:3]  # 最多 3 个，避免按钮过多
```

---

## 五、Flutter 展示效果（线框）

```
┌─────────────────────────────────────┐
│ [管管头像] 管管                      │
│         正在帮你查…                  │
├─────────────────────────────────────┤
│                    ┌──────────────┐ │
│                    │ 我手有点粗糙 │ │  ← 用户
│                    └──────────────┘ │
│ ┌────────────────────────────────┐ │
│ │ 家里有护手霜和凡士林…           │ │  ← 助手文字
│ └────────────────────────────────┘ │
│ ┌ 护手霜 ─────────────────────┐   │
│ │ 卫生间 · 剩余 1支            │   │  ← items 卡片
│ └─────────────────────────────┘   │
│ ┌ 凡士林 ─────────────────────┐   │
│ │ 卫生间 · 剩余 1罐            │   │
│ └─────────────────────────────┘   │
│ [ 查看护手霜 ]  [ 用掉 1 个 ]      │  ← actions 按钮
│                                     │
│ (护手霜在哪) (还有什么护肤品)       │  ← suggestions
├─────────────────────────────────────┤
│ [ 输入框…                    ] [➤] │
└─────────────────────────────────────┘
```

- `primary: true` → 珊瑚填充主按钮  
- 其余 → `FilledButton.tonal` 次要按钮  
- `quick_consume` → 点击直接调 API，成功后 SnackBar 提示

---

## 六、落地顺序建议

| 阶段 | 内容 |
|------|------|
| P0 | Schema 定义 `actions[]` + Swagger 可见 |
| P1 | 服务端 `build_actions()` 规则组装（查物品、加清单） |
| P2 | Flutter 解析 actions 渲染按钮 + 跳转 |
| P3 | `quick_consume` 等原地操作 |
| P4 | 意图缓存命中时本地也能返回 actions |

---

## 七、与 Function Calling 的关系

```
用户输入
  → LLM 选工具（skill）
  → 服务端执行工具 + 规则生成 actions
  → LLM 写 text
  → 合并返回 { text, items, actions, shopping_added }
```

**actions 是服务端的「确定性输出」，不交给模型自由发挥。**
