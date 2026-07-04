# UI/PM Skills 文档评审与增强

> 日期：2026-06-22  
> 范围：`doc/design/information-architecture.md`、`doc/product/roadmap.md`

---

## 技术开发文档

### 背景

使用已安装的 **ui-ux-pro-max**、**breakdown-epic-pm**、**write-prd** skills，对信息架构与产品路线图进行评审与结构化增强，使文档与代码真源一致，并产出可执行的下一阶段 Epic。

### 改动点

#### information-architecture.md

1. 补充认证路由表（`/verify-code`、`/forgot-password`）
2. 新增 Mermaid 站点地图，覆盖 ShellRoute 四 Tab 与二级页
3. 新增「核心用户旅程」表（扫码入库、找物品、处理过期等）
4. 新增「UX 质量清单」，按 ui-ux-pro-max P1–P3 优先级标注现状与建议
5. 标注已知 UX 债务（AppBar 通知占位、盘点菜单占位），并链接 roadmap Epic
6. 各页面 wireframe 补充触控/无障碍/动效备注

#### roadmap.md

1. 新增 MVP 成功指标（KPI 基线）
2. 已知差距增加优先级列，映射到 Epic E1–E4
3. 新增「下一阶段 Epic」四节（E1 通知统一、E2 提醒同步、E3 盘点、E4 录入增强），含 Problem/Solution/Metrics/Out of Scope
4. 新增建议排期（Q3 2026 – 2027 H1）
5. 阶段 3 AI 规划补充 KPI 与决策待定项
6. 新增「阶段 2.5」桥接 MVP 与 AI 阶段
7. 新增 PRD 产出路径约定

### 影响范围

- 仅文档，无代码变更
- 下游：Epic E1 可据此撰写 `doc/product/prd/PRD-home-notification-center.md`

---

## 提测开发文档

### 验证方式

1. 对照 `HomeWareClient/lib/core/router/app_router.dart`，确认 IA 站点地图路径无遗漏
2. 打开首页点击 🔔，确认仍为占位 SnackBar（与 roadmap E1 描述一致）
3. 用户面板「盘点任务」点击无跳转（与 E3 描述一致）

### 测试点

| 项 | 预期 |
|----|------|
| IA 认证路由 | 文档含 8 条认证/家庭路径 |
| Roadmap Epic | E1–E4 均有 Problem、Metrics、Out of Scope |
| 文档交叉引用 | IA ↔ roadmap ↔ vision 链接可点击 |

### 注意事项

- Epic 排期为建议性质，需产品评审确认
- AI-2「对话替代 Tab」仍为未决策项，勿按已定方案开发
