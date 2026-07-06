# 修复管管庆祝 SnackBar initState 中访问 MediaQuery 崩溃

## 技术开发文档

### 问题
`_CelebrationContentState.initState` 中调用 `MediaQuery.disableAnimationsOf(context)`，违反 Flutter 规则：InheritedWidget 依赖不能在 `initState` 完成前建立，导致断言失败并重复抛错。

### 实现方案
1. `initState` 仅初始化 `AnimationController` 与 `_scale` 动画曲线。
2. 将「是否禁用动画」判断与 `_controller.forward()` 移至 `didChangeDependencies`。
3. 使用 `_animationStarted` 标志位，避免依赖变更时重复启动动画。

### 改动点
- `HomeWareClient/lib/presentation/common/widgets/guanguan_celebration_snackbar.dart`

### 影响范围
- 管管庆祝 SnackBar 展示路径；无 API / 数据层变更。

## 提测开发文档

### 测试点
1. 触发任意会展示管管庆祝 SnackBar 的操作（如物品处理闭环），确认不再出现 `dependOnInheritedWidgetOfExactType<MediaQuery>` 断言。
2. 正常设备上图标仍有微弹跳动画。
3. 系统开启「减少动画 / 禁用动画」时，SnackBar 仍正常显示文案，图标无弹跳（或保持静态）。

### 验证方式
- 热重载或重启 App，复现原操作并观察控制台与 UI。

### 注意事项
- 若后续在其它 Widget 的 `initState` 中使用 `Theme.of` / `MediaQuery.of` 等，同样应改到 `didChangeDependencies` 或 `build`。
