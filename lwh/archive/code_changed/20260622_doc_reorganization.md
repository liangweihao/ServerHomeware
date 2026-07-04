# doc 目录重组与文档整合

## 一、技术开发说明

### 背景

`doc/` 下原有 20+ 份 Phase 任务书（appPhase / serverPhase）、原型图、Figma 规格等，大量内容与现行代码不一致（5 Tab 导航、Clean Architecture、纯本地 Drift、未实现的 AI 功能等），易造成误导。

### 方案

1. **新建现行文档树**（`doc/README.md` 为入口）
2. **归档历史 Phase** → `doc/archive/`
3. **整合产品/设计/架构/API** 为少量「真源」文档
4. **AI 规划** 迁入 `doc/roadmap/ai-mode/` 并标注未实现
5. **`doc/rules/codestyle.mdc`** 迁至 `.cursor/rules/codestyle.mdc`

### 新目录

```
doc/
├── README.md
├── product/          vision.md, roadmap.md
├── design/           IA、design-system、auth、profile、switch-family
├── client/           architecture.md
├── server/           architecture.md, api-reference.md, deployment.md
├── roadmap/ai-mode/
├── image/            （保留截图）
└── archive/          旧 Phase + 完整 Figma + 旧原型
```

### 删除 / 移除的路径

| 原路径 | 处理 |
|--------|------|
| `doc/appPhase/` | 整目录移至 `archive/client-phase-specs/` 后删除 |
| `doc/serverPhase/` | 整目录移至 `archive/server-phase-specs/` 后删除 |
| `doc/AI驱动APP/` | 文件移至 `roadmap/ai-mode/` 后删除目录 |
| `doc/重新定义家庭物品管理.md` | → `product/vision.md`，原文件归档 |
| `doc/fimga 组件.md` | → `archive/figma-design-system-full.md` |
| `doc/rules/codestyle.mdc` | → `.cursor/rules/codestyle.mdc` |

### 其他更新

- `CLAUDE.md` 增加指向 `doc/README.md` 的说明
- 设计文档主色统一说明：`#2196F3` 为准

---

## 二、提测 / 验证

| 项 | 方式 |
|----|------|
| 文档链接 | 打开 `doc/README.md`，逐一点击子链接确认可访问 |
| 与代码一致 | 对照 `app_router.dart`（4 Tab）、`api/router.py`（API 模块） |
| 归档只读 | 确认 `doc/archive/` 含 Phase 1–9 与旧原型 |
| Agent 规则 | 确认 `.cursor/rules/codestyle.mdc` 存在且示例为 Flutter 栈 |

### 注意事项

- 代码内注释若仍引用 `doc/原型图.md`、`doc/appPhase/*`，应逐步改为 `doc/design/information-architecture.md`
- API 字段以 OpenAPI + `lwh/code_changed/` 为准，非 archive 内 Phase 2 原文
