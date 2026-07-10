# 问管管 — 已删物品仍展示卡片 & 点击恢复

## 问题

`ItemDeletedRegistry` 登记 serverId=1 后，`AssistantItemResolver.resolve` 直接丢弃物品，卡片不显示；但管管仍从服务端查到「十斤羊肉」。

## 修复

1. **`resolve()`**：无法本地解析时仍保留卡片（`itemId=0`, `serverItemId=1`）
2. **卡片 UI**：显示「云端库存 · 点击恢复查看」
3. **`resolveNavIdForTap()`**：用户点击时若服务端仍有该物品 → `unmark` 删除登记 → 拉取入库 → 跳转详情

## 提测

Hot Restart 后问「羊肉在哪」：
- 应出现「十斤羊肉」卡片
- 点击后恢复并进入详情（日志 `问管管点击恢复 serverId=1`）
