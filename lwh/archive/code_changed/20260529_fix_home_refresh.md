# 修复首页返回后数据不刷新

## 问题

从物品详情页保存/编辑物品后 `pop` 回到首页，首页的统计数据、空间列表、最近动态没有自动刷新。用户必须手动下拉才能看到更新后的数据。

## 根因

首页是 `ConsumerWidget`，数据通过 `homeStatsProvider`、`spacesProvider`、`recentActivitiesProvider` 三个 FutureProvider 加载。这些 provider 只在手动 `RefreshIndicator` 下拉时被 invalidate。GoRouter 的 ShellRoute 内部 push/pop 不会触发首页 widget 重建，因此从详情页返回后数据仍为缓存旧值。

## 修复方案

采用 Flutter 标准模式 **RouteObserver + RouteAware** 监听页面可见性变化：

1. **`app_router.dart`**: 创建全局 `RouteObserver<ModalRoute>` 并传入 GoRouter 的 `observers`
2. **`home_page.dart`**: 
   - `ConsumerWidget` → `ConsumerStatefulWidget`（RouteAware 需要 StatefulWidget）
   - 混入 `RouteAware`，在 `didChangeDependencies` 中订阅，在 `dispose` 中取消订阅
   - 重写 `didPopNext()`：当其他页面 pop 后首页重新可见时，invalidate 三个数据 provider

## 影响范围

| 文件 | 改动 |
|------|------|
| `lib/core/router/app_router.dart` | +4 行：导出 `routeObserver`，GoRouter 注册 observer |
| `lib/presentation/home/home_page.dart` | +33 行：转换为 ConsumerStatefulWidget + RouteAware |

## 测试点

- [ ] 从首页进入物品详情页 → 编辑保存 → 返回，首页统计数据自动刷新
- [ ] 从首页进入物品详情页 → 删除物品 → 返回，首页数据自动刷新
- [ ] 从首页进入添加物品页 → 添加完成 → 返回，首页数据自动刷新
- [ ] 首页手动下拉刷新仍正常工作
- [ ] 切换 Tab 后返回首页，数据正常刷新

## 注意事项

- `routeObserver` 在所有页面共享，GoRouter 下 Shel​lRoute 的嵌套 Navigator 也受其监听
- `didPopNext()` 仅在从上方 pop 后触发，不会在首次加载或 Tab 切换时误触发
