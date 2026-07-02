# A/B/C 三线并行执行 — E3 盘点 + E4 录入 + 个人中心收尾

**日期**：2026-07-02  
**状态**：已实施

---

## 一、技术开发文档

### A — Epic E3 盘点任务深化

| 改动 | 说明 |
|------|------|
| `app_database.dart` | 新增 `getItemsInLocationTree()` — 含子空间使用中物品 |
| `inventory_task_provider.dart` | 递归加载物品；过期/临期统计；修正明细；空空间完成 |
| `inventory_task_storage.dart` | 历史记录扩展：修正明细、过期/临期计数 |
| `inventory_task_page.dart` | 进度条；空间物品数；报告修正明细；每月提醒开关 |
| `inventory_reminder_prefs.dart` | 本地提醒偏好 |
| `notification_scheduler.dart` | `inventory_channel` + 每月本地盘点提醒 |
| `main.dart` | 启动时调度盘点提醒 |

**架构**：盘点仍纯客户端；提醒为零服务端成本的本地通知。

### B — Epic E4 录入/扫码体验

| 改动 | 说明 |
|------|------|
| `add_item_page.dart` | 未识别条码降级 Step2；扫码草稿冲突提示；预填步骤标记 |
| `add_item_wizard_view.dart` | `completedThroughStep` 指示器勾号；扫码用 `go` 避免栈重复 |
| `scan_page.dart` | 导航改 `go`；新增「改用手动向导」 |
| `add_item_method_page.dart` | 草稿卡片摘要（名称/步骤/时间）；返回后刷新 |
| `item_list_page.dart` | FAB / 空状态统一走 `/items/add/method` |

### C — 个人中心收尾

| 改动 | 说明 |
|------|------|
| `profile_health_export_service.dart` | 健康分历史 CSV 导出 + 系统分享 |
| `profile_health_trend_card.dart` | 趋势卡右上角导出按钮 |
| `family_contribution_provider.dart` | `memberOperationTypeStatsProvider` |
| `member_operation_type_chart.dart` | 操作类型饼图（fl_chart PieChart） |
| `member_contribution_detail_body.dart` | 成员详情嵌入操作类型分布 |

---

## 二、提测开发文档

### A — 盘点（E3）

| ID | 场景 | 预期 |
|----|------|------|
| A-T1 | 选「厨房」等顶层空间 | 列表含子位置（如冰箱）物品 |
| A-T2 | 逐项核对 | 进度条随 done/total 变化 |
| A-T3 | 修正数量 | 报告展示修正明细；服务端 sync |
| A-T4 | 空空间 | 「确认空空间」可完成并写历史 |
| A-T5 | 每月提醒开关 | 关闭后无通知；开启后本地调度 |
| A-T6 | 过期/临期物品 | 清单与报告展示预警计数 |

### B — 录入（E4）

| ID | 场景 | 预期 |
|----|------|------|
| B-T1 | 扫码识别成功 | 跳 Step3；Step1/2 显示 ✓ |
| B-T2 | 扫码未识别 | 降级 Step2 填名称 |
| B-T3 | 有草稿时扫码 | 弹窗：恢复草稿 / 继续扫码 |
| B-T4 | 方式页草稿 | 显示名称、步骤、保存时间 |
| B-T5 | 物品列表 FAB | 进入方式选择页而非直接向导 |
| B-T6 | 扫码页 | 「改用手动向导」可用 |

### C — 个人中心

| ID | 场景 | 预期 |
|----|------|------|
| C-T1 | 健康分趋势 ≥2 天 | 右上角导出 CSV 可分享 |
| C-T2 | 成员详情 | 有操作时显示「操作类型分布」饼图 |
| C-T3 | 无操作记录 | 饼图区块不显示 |

### 验证命令

```powershell
cd HomeWareClient
flutter analyze
flutter test test/presentation/inventory/inventory_task_storage_test.dart
```

---

## 三、影响范围

- **客户端**：盘点、录入、个人中心
- **后端**：无变更
- **OCR**：仍暂缓（见 `20260702_ocr_local_only_decision.md`）

---

## 四、后续可选

- 盘点：多空间月度任务、Drift 会话持久化
- 录入：位置步软必填提示
- 个人中心：操作类型分布导出、健康分 PNG 海报
