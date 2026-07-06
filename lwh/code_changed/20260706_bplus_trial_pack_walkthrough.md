# B+ 店主试用包 — 演示 seed + 走查脚本

> 日期：2026-07-06  
> 范围：HomeWareServer 脚本 + 产品文档

---

## 技术开发文档

### 1. 演示 seed 脚本

**路径**：`HomeWareServer/scripts/seed_shop_demo.py`

**能力**：
- 创建 3 个演示账号（店主 / 店员 / 家庭用户），密码 `demo123456`
- shop 空间「演示便利店」：15 个预置 SKU（含低库存、售价、供应商）
- home 空间「演示家庭」：7 个物品（含临期牛奶、低库存酱油）
- 店员自动加入 shop，角色 `clerk`
- 幂等：用户/空间已存在则跳过；物品已存在则跳过（`--force-items` 可重建）

**依赖**：需先 `alembic upgrade head`（含 `sale_price`/`supplier` 迁移）；home 物品依赖 `seed_data.py` 系统分类。

### 2. 走查文档

| 文档 | 用途 |
|------|------|
| `doc/product/phase-b-plus-trial-walkthrough.md` | 一页式操作指南（SB + B+ + ST + 反馈表） |
| `doc/product/phase-b-plus-gate.md` | B+ Gate 结论与正式通过条件 |
| `doc/trial/shop_demo_import_sample.csv` | CSV 批量进货样例 |
| `doc/trial/README.md` | 素材索引 |

### 3. 产品状态更新

- `current-phase.md`：B+ Gate 自测通过、试用包就绪、Phase C 排期表
- `phase-a-gate.md`：研发自测通过
- `phase-b-gate.md`：下一步指向外测
- `roadmap.md`：试用包交付物、E3 骨架状态

---

## 提测开发文档

### 验证步骤

```powershell
cd HomeWareServer
$env:ENV_FILE=".env.dev"
alembic upgrade head
python scripts/seed_shop_demo.py
```

1. **店主登录** `13800000001` → 确认 15+ 商品、红牛在 A架
2. **SB-1** 问管管「红牛在哪」→ ≤10s
3. **B+-1** 卖出 3 次 → 首页日销/统计毛利
4. **B+-4** 导入 `doc/trial/shop_demo_import_sample.csv`
5. **ST-2** 店员 `13800000002` → 无改价字段、无 CSV 入口
6. **SB-5** 家庭 `13800000003` → 「用了 1」、临期牛奶

### 注意事项

- 客户端首次登录演示账号需联网同步服务端数据
- 日销统计基于**本地** usage_records，卖出后需在本机操作
- 外测正式 Gate 仍需 ≥3 真实店主 + 2 周 P0 观察

### 影响范围

- 仅新增脚本与文档，无业务代码变更
- seed 脚本仅写入演示手机号账号，不影响现有用户
