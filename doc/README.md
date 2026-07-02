# HomeStock 文档索引

> **HomeStock（家庭物品管家）** — Flutter 客户端 + FastAPI 服务端的家庭库存管理系统。  
> 代码仓库：`HomeWareClient/`、`HomeWareServer/`。开发速查见根目录 [`CLAUDE.md`](../CLAUDE.md)。

---

## 先读什么

| 读者 | 推荐路径 |
|------|----------|
| 新成员了解产品 | [product/vision.md](product/vision.md) → [product/roadmap.md](product/roadmap.md) |
| 前端 / UI | [design/ui_system.md](design/ui_system.md) → [design-system.md](design/design-system.md) → [add-item-redesign.md](design/add-item-redesign.md) |
| 客户端开发 | [client/architecture.md](client/architecture.md) + `HomeWareClient/lib/core/router/app_router.dart` |
| 后端开发 | [server/architecture.md](server/architecture.md) → [server/api-reference.md](server/api-reference.md) |
| 部署运维 | [server/deployment.md](server/deployment.md) |
| 近期 API / 行为变更 | [`lwh/code_changed/`](../lwh/code_changed/)（**以代码变更记录为准**） |

---

## 目录结构

```
doc/
├── README.md                          ← 本文件
├── product/                           产品与规划
│   ├── vision.md                      产品愿景与核心维度
│   ├── roadmap.md                     已交付 vs 规划中功能
│   └── prd/                           功能 PRD（write-prd 模板）
│       └── PRD-home-notification-center.md  Epic E1 首页通知中心
├── design/                            UI / 交互（与当前实现对齐）
│   ├── information-architecture.md    信息架构 + 文字版效果图
│   ├── ui_system.md                   **UI 规范（首选）**：组件、模板、约束
│   ├── design-system.md               设计 Token 与组件索引
│   ├── visual-refresh.md              全局视觉刷新（主色等）
│   ├── add-item-redesign.md           添加物品页改版规格
│   ├── home-and-list-redesign.md      首页与物品列表改版规格
│   ├── auth-onboarding.md             登录注册与引导
│   ├── profile-and-family.md          用户面板与家庭管理
│   └── switch-family-sheet.md         切换家庭弹窗
├── client/                            Flutter 客户端
│   └── architecture.md                架构与数据流（现行）
├── server/                            FastAPI 服务端
│   ├── architecture.md                三层架构与配置
│   ├── api-reference.md               API 模块索引
│   └── deployment.md                  部署与上线
├── roadmap/                           未实现规划
│   └── ai-mode/                       AI 对话模式（未开发）
├── image/                             界面截图参考
└── archive/                           历史 Phase 文档（只读归档）
```

---

## 文档维护约定

1. **现行文档**（`product/`、`design/`、`client/`、`server/`）必须与代码一致；发现偏差优先改文档。
2. **变更记录**：功能改动后同步写 `lwh/code_changed/YYYYMMDD_*.md`。
3. **归档文档**（`archive/`）为历史 Phase 任务书，**勿作为实现依据**（含 5 Tab 导航、Clean Architecture 等已废弃描述）。
4. **OpenAPI**：本地启动服务后访问 `http://localhost:8000/docs` 获取最新请求/响应 Schema。

---

## 与旧文档的对应关系

| 旧路径（已移除/归档） | 新路径 |
|----------------------|--------|
| `doc/appPhase/Phase 1–6` | `doc/archive/client-phase-specs/` |
| `doc/appPhase/原型图.md` | `doc/design/information-architecture.md`（已更新）+ `doc/archive/prototype-wireframes-v1.md` |
| `doc/serverPhase/Phase 1–6` | `doc/archive/server-phase-specs/` + `doc/server/api-reference.md` |
| `doc/重新定义家庭物品管理.md` | `doc/product/vision.md` |
| `doc/fimga 组件.md` | `doc/design/design-system.md`（精简）+ `doc/archive/figma-design-system-full.md` |
| `doc/AI驱动APP/*` | `doc/roadmap/ai-mode/` |
| `doc/rules/codestyle.mdc` | `.cursor/rules/codestyle.mdc` |
