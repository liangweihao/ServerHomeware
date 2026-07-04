# 文档归档说明

本目录保存 **历史 Phase 任务书** 与 **已被取代的规格**，仅供追溯，**勿作为开发依据**。

---

## 为何归档

| 问题 | 说明 |
|------|------|
| 5 Tab / 4 Tab 底部导航 | 已改为**单页首页** + push 导航 |
| 青松 Teal 主色 | 已改为 **utilityClean** 橙黄配色 |
| Clean Architecture | 客户端未采用 `domain/`、`usecases/` |
| 纯本地 Drift | 现为 API + Drift 混合 + WebSocket |
| Phase 任务清单 | MVP 已基本完成，细节与 OpenAPI 不一致 |

---

## 目录

| 路径 | 内容 |
|------|------|
| `client-phase-specs/` | 原 `doc/appPhase/Phase 1–9`、旧原型图 |
| `server-phase-specs/` | 原 `doc/serverPhase/Phase 1–7` |
| `design/` | 已废弃设计稿（Teal 主色、旧首页改版 v0.1） |
| `prototype-wireframes-v1.md` | 5 Tab 时代 ASCII 线框 |
| `figma-design-system-full.md` | 完整 Figma 组件描述 |
| `product-vision-original.md` | 愿景文档归档副本 |

---

## 现行文档入口

请从 [`doc/README.md`](../README.md) 开始，核心逻辑见 [`doc/core/`](../core/)。
