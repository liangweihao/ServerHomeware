# 店主试用素材

| 文件 | 说明 |
|------|------|
| [shop_demo_import_sample.csv](shop_demo_import_sample.csv) | CSV 批量进货走查样例（3 行） |
| [../product/phase-b-plus-trial-walkthrough.md](../product/phase-b-plus-trial-walkthrough.md) | 完整走查脚本 |

**演示账号**（需先执行 seed）：

```powershell
cd HomeWareServer
$env:ENV_FILE=".env.dev"
python scripts/seed_shop_demo.py
```

- 店主：`13800000001` / `demo123456`
- 店员：`13800000002` / `demo123456`
- 家庭：`13800000003` / `demo123456`
