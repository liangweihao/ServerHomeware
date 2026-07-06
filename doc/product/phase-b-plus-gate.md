# Phase B+ Gate 验证

> **状态**：🟢 **研发自测通过**（2026-07-06）— 待 ≥3 店主外测正式通过  
> **前置**：Phase B Gate 暂定通过 + B+ 全项编码 + 店员 Epic E1～E3  
> **走查脚本**：[phase-b-plus-trial-walkthrough.md](phase-b-plus-trial-walkthrough.md)

---

## 一、Gate 范围

在 Phase B（店铺皮肤 MVP）基础上，验收 B+ 增量：

| # | 能力 | 编码 | 自测 |
|---|------|------|------|
| 1 | `sale_price` 售价 | ✅ | ✅ |
| 2 | 简易日销（近 7 日） | ✅ | ✅ |
| 3 | CSV 批量进货 + bulk API | ✅ | ✅ |
| 4 | 供应商 `supplier` | ✅ | ✅ |
| 5 | 毛利报表（KPI + 双柱图） | ✅ | ✅ |
| 6 | CSV 库存导出 | ✅ | ✅ |
| 7 | 店员角色 `clerk` | ✅ | ✅ |

**正式通过**：SB-1～5 + B+-1～5 + ST-1～5 由 **≥3 位真实店主** 走查，且 shop 路径 **连续 2 周无 P0**。

---

## 二、走查清单

### 2.1 Phase B 回归（SB）

| ID | 结果 | 备注 |
|----|------|------|
| SB-1～SB-5 | ✅ 研发自测通过 | 见 [phase-b-gate.md](phase-b-gate.md) |

### 2.2 B+ 增量（B+-）

| ID | 场景 | 结果 |
|----|------|------|
| B+-1 | 卖出 → 日销/毛利/统计图 | ✅ |
| B+-2 | 售价展示（shop 表单/详情） | ✅ |
| B+-3 | CSV 库存导出 | ✅ |
| B+-4 | CSV 导入闭环（bulk API） | ✅ |
| B+-5 | 供应商字段全链路 | ✅ |

### 2.3 店员角色（ST）

| ID | 场景 | 结果 |
|----|------|------|
| ST-1 | shop 加入默认 clerk | ✅ |
| ST-2 | 店员不可改价/供应商 | ✅ |
| ST-3 | 店员可卖出/进货 | ✅ |
| ST-4 | 店员不可 CSV bulk | ✅ |
| ST-5 | 老板改角色页 | ✅ |

**自动化**：`pytest tests/test_shop_permissions.py`（8 passed）；`flutter test test/core/auth/shop_role_guard_test.dart`（4 passed）

---

## 三、试用包交付物

| 交付物 | 路径 |
|--------|------|
| 演示 seed 脚本 | `HomeWareServer/scripts/seed_shop_demo.py` |
| 走查一页纸 | [phase-b-plus-trial-walkthrough.md](phase-b-plus-trial-walkthrough.md) |
| CSV 样例 | [doc/trial/shop_demo_import_sample.csv](../trial/shop_demo_import_sample.csv) |
| 店员 PRD | [phase-b-staff-role-prd.md](phase-b-staff-role-prd.md) |

---

## 四、Gate 结论

| 项 | 结论 |
|----|------|
| B+ 编码完成度 | ✅ 100% |
| 研发自测（SB + B+ + ST） | 🟢 **通过** |
| 店主外测 | ⬜ 待执行（目标 ≥3 人） |
| 2 周 P0 观察 | ⬜ 待启动 |
| **综合** | 🟢 **可发试用包** — 正式 Gate 待外测 |

---

## 五、通过后下一步

1. **外测执行**：按走查脚本收集 ≥3 店主反馈  
2. **Phase A Gate**：家庭路径并行走查（[phase-a-gate.md](phase-a-gate.md)）  
3. **Phase C 立项**：见 [current-phase.md](current-phase.md) §Phase C

变更记录：[lwh/code_changed/20260706_bplus_trial_pack_walkthrough.md](../../lwh/code_changed/20260706_bplus_trial_pack_walkthrough.md)
