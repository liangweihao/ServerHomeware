# 文档整合与废弃清理

**日期**：2026-07-04  
**状态**：已完成

---

## 一、技术开发说明

### 背景

项目积累 100+ 份 `lwh/code_changed/` 变更记录和 40+ 份 `doc/` 文档，存在以下问题：

1. 导航描述过时（4 Tab → 实际为单页首页）
2. 主题描述过时（Teal → utilityClean）
3. 缺少统一的系统逻辑与流程图真源
4. 大量执行计划、主题实验、验收清单与现行代码无关

### 方案

1. **新建 `doc/core/`** 作为系统逻辑真源，含 Mermaid 流程图
2. **更新现行文档**（README、architecture、roadmap、IA、ai-mode）
3. **新建 `doc/product/current-phase.md`** 整合 Phase A 方向
4. **归档废弃设计文档** → `doc/archive/design/`
5. **整理 `lwh/code_changed/`** — 43 份移入 `lwh/archive/code_changed/`，新建 `lwh/README.md` 索引

### 新增文档

| 路径 | 内容 |
|------|------|
| `doc/core/system-overview.md` | 系统架构、模块地图、实现状态 |
| `doc/core/business-flows.md` | 认证/录入/消耗/同步/提醒/问管家流程图 |
| `doc/product/current-phase.md` | Phase A 方向与里程碑 |
| `lwh/README.md` | 知识库索引与归档规则 |

### 更新文档

| 路径 | 主要变更 |
|------|----------|
| `doc/README.md` | 新索引结构、关键差异表 |
| `doc/client/architecture.md` | 单页首页、问管家、WS 同步 |
| `doc/server/architecture.md` | 请求流程、WS 广播流程图 |
| `doc/product/roadmap.md` | M1-M3 状态、问管家已交付 |
| `doc/design/information-architecture.md` | 移除 4 Tab，更新首页线框 |
| `doc/roadmap/ai-mode/README.md` | 标注 Phase 1 已实现 |
| `doc/archive/README.md` | 补充 design/ 归档说明 |

### 归档/删除

| 原路径 | 处理 |
|--------|------|
| `doc/design/visual-refresh.md` | → `doc/archive/design/visual-refresh-teal-v0.1.md` |
| `doc/design/home-and-list-redesign.md` | → `doc/archive/design/home-and-list-redesign-v0.1.md` |
| `lwh/code_changed/` 中 43 份 | → `lwh/archive/code_changed/` |

### 影响范围

- 仅文档变更，无代码改动
- Agent 检索应优先 `doc/core/` + `lwh/README.md`
- 旧链接若指向已移动文件，需改用 `doc/` 或 `lwh/archive/` 路径

---

## 二、提测说明

| 项 | 验证方式 |
|----|----------|
| 文档链接 | 打开 `doc/README.md`，逐一点击子链接 |
| 与代码一致 | 对照 `app_router.dart`（单页首页）、`assistant/`（问管家）、`ui_system.md`（utilityClean） |
| 流程图渲染 | Markdown 预览中 Mermaid 图正常显示 |
| 归档完整 | `lwh/archive/code_changed/` 含 43 份；`code_changed/` 剩 63 份活跃记录 |
| 无断链 | `current-phase.md` 引用 archive 路径正确 |

### 注意事项

- 代码内注释若仍引用 4 Tab / Teal 主色，应逐步改为 `doc/core/`
- 新功能交付仍写 `lwh/code_changed/`，执行计划在完成后移入 archive
