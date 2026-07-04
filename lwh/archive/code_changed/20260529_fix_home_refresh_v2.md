# 修复首页返回后不刷新（第二版）

## 问题

上一个 RouteAware + RouteObserver 方案仍然不生效。从物品详情页保存/编辑后返回首页，数据依旧没有刷新。

## 根因分析

GoRouter 的路由结构:

```
GoRouter (顶层 Navigator)
├── ShellRoute (嵌套 Navigator)
│   ├── /          (HomePage)
│   ├── /items     (ItemListPage)
│   └── ...
├── /items/:id     (ItemDetailPage)  ← 在顶层 Navigator push/pop
└── ...
```

RouteAware 订阅的是 HomePage 在 **嵌套 Navigator** 中的 ModalRoute。但物品详情页 `/items/:id` 是直接 push 到 **顶层 Navigator** 的——嵌套 Navigator 没有发生 push/pop，所以 `didPopNext()` 永远不会触发。

## 修复方案

废弃 RouteAware，改用 **GoRouter location 变化检测**:

在 build 方法中通过 `GoRouterState.of(context).uri` 监听顶层路由变化（GoRouterState 是 InheritedWidget，级联通知所有依赖者）。用 `_previousLocation` 对比当前 location，检测到从子页面回到 `/` 时，通过 `addPostFrameCallback` 延迟执行 invalidate（避免 build 期间直接 invalidate 导致无限循环）。

核心逻辑:
```dart
final location = GoRouterState.of(context).uri.toString();
if (_previousLocation != null && _previousLocation != location && location == '/') {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(currentFamilyProvider);
    ref.invalidate(homeStatsProvider);
    ...
  });
}
_previousLocation = location;
```

## 影响范围

| 文件 | 改动 |
|------|------|
| `lib/presentation/home/home_page.dart` | 移除 RouteAware，改用 GoRouterState location 检测 |

## 测试点

- [ ] 从首页进入物品详情 → 编辑保存 → 返回，首页数据自动刷新
- [ ] 从首页进入物品详情 → 删除 → 返回，首页数据自动刷新
- [ ] 从首页进入添加物品 → 添加完成 → 返回，首页数据自动刷新
- [ ] 切换 Tab 后返回首页，数据不受影响
- [ ] 首次加载首页不重复刷新
