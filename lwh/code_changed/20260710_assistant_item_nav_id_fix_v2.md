# 问管管物品卡片 navId=1 误跳转 — 二次修复

## 根因

本地 Drift 存在 **id=1 的其他物品**（或服务端 id 与本地主键冲突）时，`ensureLocalByServerId(1)` 误把 id=1 当作目标物品，详情页 `getItemById(1)` 实际不是「十斤羊肉」或不存在。

## 修复

1. **`ensureLocalByServerId`**：仅当 `serverItemId` 映射一致才复用本地 id；冲突时用自增 id 新插入
2. **`AssistantItemResolver`**：解析后 **校验本地行存在且名称匹配**；优先 `getItemByServerItemId`
3. **点击卡片**：再次 resolve + 已删除物品提示

## 提测

**请 Hot Restart（非 Hot Reload）** 后：
- 点击「十斤羊肉」卡片
- 日志应含 `localId=... serverId=1`，且能进入详情
- 若物品已删除，提示「已删除，无法打开详情」
