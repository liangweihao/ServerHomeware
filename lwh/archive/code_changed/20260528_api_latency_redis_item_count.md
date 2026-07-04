# 接口耗时优化（Redis + item_count + 个人面板）

## 问题

- 每个需认证接口在 `get_redis_optional()` 中 `redis.ping()`，Redis 不可达时单次请求阻塞约 4s
- `get_family_item_count` 通过 `get_list` 同时执行 COUNT 子查询 + LIMIT 20 列表查询
- 个人面板与首页重复调用 `GET /families/current`，且三块数据共用一个 loading

## 改动

| 文件 | 变更 |
|------|------|
| `HomeWareServer/app/core/dependencies.py` | 开发环境跳过 Redis；生产环境 ping 超时 0.5s |
| `HomeWareServer/app/repositories/item_repo.py` | 新增 `count_by_family_id` |
| `HomeWareServer/app/services/family_service.py` | `get_family_item_count` 改用 COUNT |
| `HomeWareClient/.../profile_panel_page.dart` | 复用 `currentFamilyProvider`；家庭/贡献度分块加载 |

## 提测要点

1. 重启后端，打开个人面板：三个接口耗时应从 ~4s 降至百毫秒级（开发环境）
2. 日志中不应再出现 `SELECT items ... LIMIT 20` 仅用于统计 item_count
3. 从首页进入个人面板：家庭信息应能先显示（缓存），贡献度可后加载
4. 切换家庭后下拉/重载：家庭名与邀请码应更新
