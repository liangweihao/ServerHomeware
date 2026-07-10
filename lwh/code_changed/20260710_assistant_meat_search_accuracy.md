# 问管管「想吃肉」误报肉松 — 搜索精度与防编造

## 问题

用户发送「我想吃肉」，管管回复「家里有 1 件肉松…可能在零食柜或冰箱附近」。用户反馈**家里没有肉松**。

可能原因：
1. 本地 Drift 快照仍含已用完/数量为 0 的「肉松」条目
2. LLM 用「肉松」等具体品名查库，而非用「肉」泛搜
3. 模糊匹配 `name in key / key in name` 过宽
4. 工具返回「未指定位置」后，LLM 编造「可能在零食柜」

## 实现方案

### 服务端 `llm_service.py`

1. **匹配评分** `_score_item_name_match`：完全一致 > 前缀 > 包含；单字关键词降权
2. **`_rank_item_results`**：按得分排序，过滤 `quantity <= 0` 和低相关度结果
3. **`query_item_stock`**：合并服务端 + 本地快照去重；泛化词（如「肉」）返回最多 10 条并带 `broad_search` 提示
4. **系统提示词**：禁止编造数量/位置；「想吃肉」须用「肉」查库并列出全部结果
5. **工具描述**：明确泛化需求勿臆测具体品名
6. **日志**：打印工具命中品名列表，便于对照 Drift 快照

### 客户端 `assistant_local_inventory.dart`

1. 快照仅上传 `status==0 && currentQuantity > 0`
2. 调试日志：打印快照中含「肉」的品名与数量

## 改动文件

| 文件 | 改动 |
|------|------|
| `HomeWareServer/app/services/llm_service.py` | 评分搜索、合并去重、提示词、日志 |
| `HomeWareClient/lib/core/assistant/assistant_local_inventory.dart` | 过滤零库存、肉品 debug 日志 |

## 提测要点

1. **重启后端**（改 Python 需 reload）
2. **热重载/重启 App** 后发送「我想吃肉」
3. 期望：
   - 若本地无含「肉」且 quantity>0 的物品 → 明确说没有相关库存
   - 若有猪肉/牛肉等 → 列出全部，不单独捏造「肉松」
   - 位置仅来自工具 `location` 字段
4. 查看 Logcat：
   - `[AssistantLocalInventory] INFO: 快照含「肉」品名 meatLike=...`
   - 服务端 `[LlmService] INFO: 库存命中 keyword=... names=...`
5. 若 `meatLike` 仍含「肉松」但用户确认无此物 → 在物品页删除或修正该条目后重试

## 注意事项

- 服务端 items 表若仍为空，问管管主要依赖 `local_items` 快照
- 若 LLM 仍调用 `item_name=肉松` 而非 `肉`，日志中 `keyword=肉松` 可定位；需对照快照是否真有该条目
