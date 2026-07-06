# Phase B 小店铺皮肤立项

**日期**：2026-07-04  
**状态**：立项文档已交付，**B1 编码未启动**  
**真源**：[doc/product/phase-b-shop-skin-prd.md](../../doc/product/phase-b-shop-skin-prd.md)

---

## 一、交付物

| 文档 | 内容 |
|------|------|
| `doc/product/phase-b-shop-skin-prd.md` | 背景、MVP 范围、技术方案、Gate 预览、风险 |
| `doc/product/phase-b-milestones.md` | B1～B4 任务拆解 + 验收清单 |
| `doc/product/current-phase.md` | Phase B 章节索引 |
| `doc/product/roadmap.md` | 阶段 4 状态更新 |
| `doc/README.md` | 产品路径索引 |

---

## 二、Phase B 一句话

同一 App + 同一 `Family` 租户，通过 `space_type=shop` 切换 **文案皮肤 + 默认模板 + 管管词表 + 断货优先**，服务小店主「10 秒查库存、要不要补货」。

---

## 三、MVP 边界（锁 scope）

**做**：B1～B4（类型、皮肤、seed、管管/危机）  
**不做**：售价、毛利、CSV、供应商、ERP（归 B+）

---

## 四、开编码前条件（任一）

1. Phase A Gate 通过 + 2 周无 P0  
2. 家庭深度用户占比达标  
3. ≥3 小店主样本 + 愿付费信号  

---

## 五、建议下一步

| 顺序 | 动作 | 负责 |
|------|------|------|
| 1 | Phase A Gate 走查收尾 | 产品/测试 |
| 2 | B1 技术评审（`families.space_type`） | 研发 |
| 3 | 店铺 seed 分类/位置设计稿确认 | 产品/设计 |
| 4 | 启动 B1 编码 | 研发 |

### B1 首个 PR

- 后端：`space_type` 迁移 + API  
- 客户端：家庭创建二选一 + `spaceSkinProvider` 骨架（可先只读 home）

---

## 六、管管关联

- P2 周报 Insight 在 B2 换「后厨档口」文案  
- `GuanguanCopy` 改为委托 `SpaceSkinConfig`（B2 实现）
