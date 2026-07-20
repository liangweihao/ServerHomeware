# 魔法备注 + 检索别名（问管管语义命中）

**日期**：2026-07-20  
**模块**：server + client

---

## 背景

入库「韩束精华露」后，问管管「护肤霜」因纯名称子串匹配找不到。  
同时用户填备注费劲。将两者合并：入库时一键生成**口语备注 + 检索别名**。

## 方案

```
入库页备注栏 → 点 ✨ 魔法
  → POST /assistant/enrich-item
  → { notes, search_aliases }
  → 填入备注框 + 暂存 aliases
  → 保存物品时写入 items.search_aliases

问管管 query_item_stock
  → name ILIKE 或 search_aliases ILIKE
  → 本地快照同样带 search_aliases 参与打分
```

## 改动

### 服务端
- `0014_add_search_aliases`：`items.search_aliases` Text（JSON 数组）
- `item_enrich_service.py`：DeepSeek 生成备注/别名（可降级）
- `POST /assistant/enrich-item`
- `Item` / Create/Update/Response 支持 `search_aliases`
- `search_by_name` + LLM 打分支持别名

### 客户端
- Drift schemaVersion=9，`searchAliases`
- `NotesMagicField`：备注框右侧 `auto_awesome` 魔法按钮（向导 + 表单）
- 同步 / 本地库存快照携带 aliases

## 验证

1. 入库填「韩束精华露」+ 分类个护 → 点魔法 → 备注生成，SnackBar 提示检索词  
2. 保存后问管管「护肤霜」/「精华」应能命中  
3. 无 DEEPSEEK_KEY 时仍有降级备注（名称+品牌+分类）

## 注意

- 旧物品无 aliases，需再点一次魔法并保存，或后续做批量回填  
- 别名不宜过宽，服务端 prompt 已限制条数与相关度
