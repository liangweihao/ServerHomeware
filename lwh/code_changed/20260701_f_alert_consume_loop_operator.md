# F 阶段：提醒→详情→记消耗闭环 + 操作人写入

## 技术开发文档

### 背景

提醒中心「今天用掉/已丢弃」与记消耗链路各自写库，未记录操作人，家庭贡献排行不准确；从提醒点进详情后仍需多次点击才能完成处理。

### 实现方案

1. 在 `usage_dialog.dart` 抽取统一动作：
   - `resolveUsageOperatorName` — 当前用户昵称/手机号
   - `applyItemUsage` — 记消耗 + 服务端同步 + `invalidateAlertProviders`
   - `recordItemDiscard` — 丢弃 + 操作人 + 刷新提醒
   - `recordQuickUsage` — 一键 1 件，默认带操作人

2. 提醒中心改用上述 API，去掉重复 Drift 写入。

3. 物品详情支持路由参数：
   - `?action=consume` — 进入后自动打开记消耗弹窗
   - `?alert=expiry` 等 — 顶部展示 `ItemAlertContextBanner` 快捷操作

4. 提醒中心 / 通知中心跳转过期提醒时携带 `action=consume&alert=...`。

### 改动文件

| 文件 | 说明 |
|------|------|
| `usage_dialog.dart` | 统一 usage/discard 动作与操作人 |
| `item_alert_context_banner.dart` | 详情顶栏提醒上下文 + 记1件/记录/丢弃 |
| `item_detail_page.dart` | 路由参数、自动弹窗、顶栏 banner |
| `app_router.dart` | 详情页 query 传参 |
| `alert_center_page.dart` | 复用 recordQuickUsage / recordItemDiscard |
| `notification_center_page.dart` | 跳转带 alert/consume 参数 |

### 影响范围

- 提醒中心快捷操作、家庭贡献排行数据
- 通知中心 → 详情 → 记消耗路径
- 记消耗弹窗默认选中当前用户为操作人

---

## 提测开发文档

### 测试点

1. **提醒中心 · 今天用掉**：数量 -1，usage_records 含 operatorName（当前昵称）
2. **提醒中心 · 已丢弃**：status=3，记录含操作人，提醒列表刷新
3. **点击过期提醒卡片**：进入详情自动弹出记消耗；顶部 banner 显示提醒信息
4. **Banner · 记 1 件**：无弹窗直接记消耗，刷新详情与提醒
5. **通知中心**：点击过期类通知，同上闭环
6. **家庭贡献**：记消耗后 profile 贡献排行/动态出现当前用户

### 验证方式

登录有昵称的账号 → 提醒中心处理 1 条 → 我的页查看家庭贡献是否 +1。

### 注意事项

- 未登录或无昵称时操作人 fallback 手机号，仍可能显示「未署名」若两者皆空
- `action=consume` 仅在物品可消耗（status=0 且 qty>0）时弹窗
