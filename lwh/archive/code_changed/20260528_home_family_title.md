# 首页标题显示当前家庭名称

## 实现方案

- 新增 `currentFamilyProvider`（`family_provider.dart`），通过 `FamilyService.getCurrentFamily` 拉取当前选中家庭信息，与个人中心逻辑一致
- `HomePage` AppBar 标题由固定「我的家」改为展示 `family['name']`；无家庭或加载失败时显示「未加入家庭」
- 下拉刷新时 `invalidate(currentFamilyProvider)`，切换家庭后回到首页可刷新标题

## 改动点

| 文件 | 变更 |
|------|------|
| `HomeWareClient/lib/core/providers/family_provider.dart` | 新增当前家庭 Provider |
| `HomeWareClient/lib/presentation/home/home_page.dart` | 标题绑定家庭名称，刷新时失效 Provider |

## 影响范围

- 仅首页 AppBar 标题展示，不影响首页统计/空间等本地数据逻辑

## 提测要点

1. 已加入家庭：首页标题显示家庭名称（与「我的」面板「当前家庭」一致）
2. 在切换家庭弹窗切换后，下拉刷新首页，标题应更新为新家庭名
3. 未加入家庭：标题显示「未加入家庭」
4. 网络异常：标题降级为「未加入家庭」，控制台有 ERROR 日志
