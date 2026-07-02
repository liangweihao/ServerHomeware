# G+H+I：家庭贡献页、组件收尾、摘要 Chip 直达提醒

## 技术开发文档

### G — 家庭贡献独立页 + API 对齐

**服务端**
- 新增 `app/services/contribution_service.py`：从 `usage_records` 聚合本月入库/消耗
- `GET /contributions/user/{id}` 返回双字段：`record_count`/`consume_count` + `added_items`/`used_count`
- 新增 `GET /contributions/family/leaderboard` 家庭排行
- 历史接口按日返回对齐字段

**客户端**
- `contribution_stats.dart`：统一解析 API 字段
- `contribution_service.dart`：`getFamilyLeaderboard()`
- `family_contribution_provider.dart`：本地 + 服务端合并排行；动态含物品名
- `family_contribution_page.dart`：独立页 `/profile/family/contribution`
- `family_contribution_section.dart`：「查看全部」+ 动态可点进物品
- `profile_panel_page.dart`：用 `UserContributionStats.fromApi` 解析

### H — 组件收尾 + 提测清单

- `stat_card.dart`：工具风白卡 + 左侧色条（与 AlertCard 一致）
- 提测清单见本文「提测开发文档」

### I — 今日摘要 Chip → 提醒中心 Tab

- 路由 `/alerts?tab=expiry|stock|restock|warranty`
- `AlertCenterPage(initialTab)` 支持初始 Tab
- `today_summary_banner.dart`：已过期/临期 → `expiry`，低库存 → `stock`

---

## 提测开发文档（H — 全量回归清单）

### 主题与外壳
- [ ] 默认工具风：灰底、白顶栏、点评橙主色
- [ ] 首页四分区横滑、今日摘要、按空间
- [ ] WarmScaffold 页面无 Cartoon 外壳残留

### 首页与搜索
- [ ] 今日摘要点击 → 提醒中心
- [ ] Chip「已过期/临期」→ `/alerts?tab=expiry` 且 Tab 正确
- [ ] Chip「低库存」→ `/alerts?tab=stock`
- [ ] 搜索热词、分区、关联 Banner

### 录入与扫码
- [ ] 4 步向导、草稿恢复、离开保存
- [ ] 扫码预填、手动输入条码
- [ ] 扫码页四角橙框、识别跳转添加入库

### 记消耗闭环（F）
- [ ] 提醒中心「今天用掉」写 operatorName
- [ ] 点击过期提醒 → 详情弹窗 + 顶栏 banner
- [ ] Banner 记 1 件 / 记录使用 / 已丢弃
- [ ] 通知中心过期项同样闭环

### 提醒与购物
- [ ] 提醒中心 Tab 筛选、全部已读
- [ ] AlertCard TagChip + 操作按钮
- [ ] 购物清单自动推荐 TagChip、勾选/删除

### 位置与物品
- [ ] LocationCard / SpaceCard 工具风白卡
- [ ] ItemCard 工具风、详情白卡片分组
- [ ] 空态灰圆 emoji（非 SVG 卡通）

### 家庭协作（G）
- [ ] Profile 面板「我的贡献」显示录入/消耗（服务端字段）
- [ ] 「家庭协作」区块排行 + 最近动态
- [ ] 「查看全部」→ 贡献详情页
- [ ] 动态点击 → 物品详情
- [ ] 记消耗后排行更新（本地 + 联网合并）

### 统计与其他
- [ ] StatCard 工具风（若页面使用）
- [ ] 分类/家庭/通知设置等 WarmScaffold 页正常

### 验证方式
1. 真机或模拟器热重启
2. 登录有昵称账号，完成 1 次入库 + 1 次记消耗
3. 制造过期/低库存数据或 mock
4. 断网验证本地排行仍可用；联网后 `/contributions/family/leaderboard` 返回合并

### 注意事项
- 服务端贡献 API 依赖 `usage_records.family_id` 与 `operator_name` 有值
- 合并排行策略：按姓名取本地/服务端较大值，避免重复计数
