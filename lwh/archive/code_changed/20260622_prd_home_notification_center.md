# Epic E1 PRD：首页通知中心

> 日期：2026-06-22  
> 产出：`doc/product/prd/PRD-home-notification-center.md`

---

## 技术开发文档

### 实现方案概要

1. 新增全屏页 `/notifications`，替换首页 🔔 占位 SnackBar
2. 新增 Drift 表 `AlertReadStates` 持久化已读/忽略
3. 统一 `unreadAlertCountProvider`（4 类提醒），修复 `getAlertCount()` 仅统计 2 类的问题
4. 通知中心与 `/alerts` 共享提醒判定逻辑；「全部已读」写本地库
5. Epic E2（WebSocket/Push）明确 Out of Scope

### 改动文件（文档）

| 文件 | 变更 |
|------|------|
| `doc/product/prd/PRD-home-notification-center.md` | 新建，write-prd 8 段式 |
| `doc/product/roadmap.md` | E1 PRD 链接 |
| `doc/design/information-architecture.md` | 补充 `/notifications` 与 PRD 引用 |

### 影响范围

- 仅 PRD 与设计文档，**尚未编码**
- 预计客户端改动：`home_page`、`app_router`、`app_database`、新 Provider、`alert_center_page`

---

## 提测开发文档

### 验收依据

以 PRD §7.4 P0 用户故事（US-1～US-5）及 §8 Success Metrics 为准。

### 关键测试点

| ID | 场景 | 预期 |
|----|------|------|
| T1 | 有未读时点击首页 🔔 | 进入 `/notifications`，非 SnackBar |
| T2 | AppBar Badge = Tab Badge | 数字一致，含 4 类提醒 |
| T3 | 全部已读 | Badge 归零，重启仍保持 |
| T4 | 已读但未处理 | 提醒 Tab 仍可见该物品 |
| T5 | 切换家庭 | 列表与 Badge 刷新为当前家庭 |
| T6 | 空状态 | 展示引导，无硬编码红点 |

### 注意事项

- 开发前确认 Drift migration 策略
- `_markAllAsRead` 现有实现有误（清空 ignore Set），实现时需按 PRD 修正
- P1 服务端 summary 联调为可选，不阻塞 M2
