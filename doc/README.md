# HomeStock 文档索引

> **HomeStock（家庭物品管家）** — Flutter 客户端 + FastAPI 服务端的家庭库存管理系统。  
> 代码仓库：`HomeWareClient/`、`HomeWareServer/`。开发速查见根目录 [`CLAUDE.md`](../CLAUDE.md)。

---

## 先读什么

| 读者 | 推荐路径 |
|------|----------|
| **新成员快速了解** | [core/system-overview.md](core/system-overview.md) → [core/modules/](core/modules/) → [core/business-flows.md](core/business-flows.md) |
| 产品 / PM | [product/current-phase.md](product/current-phase.md) → [product/vision.md](product/vision.md) → [product/roadmap.md](product/roadmap.md) |
| 前端 / UI | [design/ui_system.md](design/ui_system.md) → [design/information-architecture.md](design/information-architecture.md) |
| 客户端开发 | [client/architecture.md](client/architecture.md) + [core/business-flows.md](core/business-flows.md) |
| 后端开发 | [server/architecture.md](server/architecture.md) → [server/api-reference.md](server/api-reference.md) |
| 部署运维 | [server/deployment.md](server/deployment.md) |
| 近期变更 | [`lwh/code_changed/`](../lwh/code_changed/)（每次交付同步） |

---

## 目录结构

```
doc/
├── README.md                          ← 本文件
├── core/                              ★ 核心逻辑与流程图（真源）
│   ├── system-overview.md             系统架构、模块地图、实现状态
│   ├── business-flows.md              认证/录入/消耗/同步/提醒/问管家流程
│   └── modules/                       ★ 按业务域拆分的模块专题
│       ├── README.md                  模块索引
│       ├── sync-and-realtime.md       同步、WebSocket、ID 映射
│       ├── assistant-guanguan.md      问管家 / 管管
│       ├── items-entry-and-consume.md 录入、消耗、提醒闭环
│       ├── auth-and-family.md         认证、家庭、贡献度
│       └── ui-and-home.md             UI 体系、单页首页
├── product/                           产品与规划
│   ├── current-phase.md               ★ Phase A 方向与里程碑（现行）
│   ├── vision.md                      产品愿景与核心维度
│   ├── roadmap.md                     已交付 vs 规划中功能
│   └── prd/                           功能 PRD
│       └── PRD-home-notification-center.md
├── design/                            UI / 交互（与当前实现对齐）
│   ├── ui_system.md                   ★ UI 规范（首选）：utilityClean
│   ├── design-system.md               设计 Token 与组件索引
│   ├── information-architecture.md    信息架构 + 路由地图
│   ├── add-item-redesign.md           添加物品页规格
│   ├── auth-onboarding.md             登录注册与引导
│   ├── profile-and-family.md          用户面板与家庭管理
│   └── switch-family-sheet.md         切换家庭弹窗
├── client/                            Flutter 客户端
│   └── architecture.md                架构与数据流
├── server/                            FastAPI 服务端
│   ├── architecture.md                三层架构与配置
│   ├── api-reference.md               API 模块索引
│   └── deployment.md                  部署与上线
├── roadmap/                           未实现规划
│   └── ai-mode/                       AI 对话增强（LLM/语音，未开发）
├── image/                             界面截图参考
└── archive/                           历史文档（只读，勿作实现依据）
```

---

## 文档维护约定

1. **核心真源**：`doc/core/` 描述系统逻辑与流程，必须与代码一致；发现偏差优先改文档。
2. **现行文档**（`product/`、`design/`、`client/`、`server/`）随功能演进更新。
3. **变更记录**：功能改动后同步写 `lwh/code_changed/YYYYMMDD_*.md`。
4. **归档文档**（`archive/`、`lwh/archive/`）为历史 Phase / 执行计划 / 已废弃设计，**勿作为实现依据**。
5. **OpenAPI**：本地启动服务后访问 `http://localhost:8000/docs` 获取最新 Schema。

---

## 与旧文档的对应关系

| 旧路径（已移除/归档） | 新路径 |
|----------------------|--------|
| `doc/appPhase/Phase 1–6` | `doc/archive/client-phase-specs/` |
| `doc/serverPhase/Phase 1–6` | `doc/archive/server-phase-specs/` + `doc/server/api-reference.md` |
| `doc/design/visual-refresh.md` | 已归档 → `doc/archive/design/visual-refresh-teal-v0.1.md` |
| `doc/design/home-and-list-redesign.md` | 已归档 → `doc/archive/design/home-and-list-redesign-v0.1.md` |
| `doc/AI驱动APP/*` | `doc/roadmap/ai-mode/` |
| `lwh/code_changed/` 中执行计划/主题实验 | `lwh/archive/code_changed/` |

---

## 关键实现差异（勿被旧文档误导）

| 旧描述 | 现行实现 |
|--------|----------|
| 4 Tab 底部导航 | **单页首页** + push 进入各功能页 |
| 青松 Teal `#3A9B8A` 主色 | **utilityClean** 橙 `#FF6633` + 黄 `#FFDA44` FAB |
| Clean Architecture domain/ | 未采用；逻辑在 services/providers |
| AI 对话未实现 | **问管家 Phase 1** 已上线（本地规则引擎） |
| 5 Tab 中间「＋」 | 首页/顶栏「+」→ 方式选择页 |
