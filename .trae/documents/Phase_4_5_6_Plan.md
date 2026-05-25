# Phase 4-6 实施计划

## 一、概述

本计划涵盖 Phase 4（智能功能）、Phase 5（增强功能）和 Phase 6（体验打磨）的完整实施。

**当前状态分析**：
- Phase 4（智能功能）：✅ 全部完成
  - 首页 Dashboard ✅
  - 搜索页 ✅
  - 购物清单页 ✅
  - 消耗预测服务 ✅
  - 购物清单自动生成 ✅
- Phase 5（增强功能）：✅ 全部完成
  - 扫码录入 ✅
  - 数据统计页 ✅
  - Profile 页面完善 ✅
  - 数据导出服务 ✅
- Phase 6（体验打磨）：✅ 全部完成
  - 空状态设计 ✅
  - 骨架屏加载 ✅
  - 错误处理 ✅
  - 删除撤销 ✅
  - 动画 & 微交互 ✅
  - 首次使用引导 ✅
  - 性能优化 ✅
  - 细节完善 ✅

---

## 二、Phase 6.1：空状态设计

### 现状分析
已实现空状态的页面：
- `alert_center_page.dart` - ✅ 有空状态 "一切安好"
- `home_page.dart` - ✅ 有空间为空、动态为空的提示
- `shopping_list_page.dart` - ✅ 有购物清单为空的提示
- `search_page.dart` - ✅ 有搜索无结果的提示

需要补充空状态的页面：
- `item_list_page.dart` - 当前是占位符，需要实现完整功能和空状态
- `statistics_page.dart` - 需要添加数据不足的空状态

### 实现方案

#### 1. item_list_page.dart 空状态
```dart
// Phase 6 文档定义：
// | 物品列表为空 | 📦 | 还没有添加物品 | 扫一扫或手动添加第一件物品吧 | + 添加第一件物品 |
AppEmptyState(
  icon: '📦',
  title: '还没有添加物品',
  subtitle: '扫一扫或手动添加第一件物品吧',
  actionLabel: '+ 添加第一件物品',
  onAction: () => context.push('/items/add'),
)
```

#### 2. statistics_page.dart 空状态
```dart
// Phase 6 文档定义：
// | 统计无数据 | 📊 | 数据不足 | 添加更多物品后可查看统计 | 无 |
AppEmptyState(
  icon: '📊',
  title: '数据不足',
  subtitle: '添加更多物品后可查看统计',
)
```

### 修改文件
1. `lib/presentation/items/item_list_page.dart` - 完整实现物品列表 + 空状态
2. `lib/presentation/statistics/statistics_page.dart` - 添加空状态

---

## 三、Phase 6.2：骨架屏加载

### 前提条件
`pubspec.yaml` 已包含 `shimmer: ^3.0.0` 依赖。

### 实现方案

#### 1. 创建通用骨架屏组件
文件：`lib/presentation/common/widgets/shimmer_loading.dart`

```dart
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
```

#### 2. 创建物品列表骨架屏
文件：`lib/presentation/items/widgets/item_list_shimmer.dart`

模拟 3-5 个 ItemCard 的占位形状：
- 左侧方块（60x60，图片占位）
- 右侧 3 行长短不一的条形（文字占位）

#### 3. 创建首页骨架屏
文件：`lib/presentation/home/widgets/home_shimmer.dart`

- 搜索栏占位
- 4 个方块（StatCard 占位）
- 横向条形列表（空间卡片占位）
- 竖向条形列表（动态占位）

#### 4. 修改页面使用骨架屏
在 `home_page.dart`、`item_list_page.dart` 等页面使用：
```dart
AsyncValue.when(
  data: (data) => ...,
  loading: () => HomeShimmer(),
  error: (e, _) => ...,
)
```

### 创建/修改文件
1. `lib/presentation/common/widgets/shimmer_loading.dart` - 新建
2. `lib/presentation/items/widgets/item_list_shimmer.dart` - 新建
3. `lib/presentation/home/widgets/home_shimmer.dart` - 新建
4. `lib/presentation/home/home_page.dart` - 添加骨架屏
5. `lib/presentation/items/item_list_page.dart` - 添加骨架屏

---

## 四、Phase 6.3：错误处理

### 实现方案

#### 1. 添加全局错误捕获
文件：`lib/main.dart`

```dart
class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(String id, ProviderBase base, Object? error, StackTrace? stackTrace) {
    // 记录错误日志
    debugPrint('Provider error: $error');
  }
}

// 在 ProviderScope 中使用
ProviderScope(
  observers: [AppProviderObserver()],
  child: MyApp(),
)
```

#### 2. 页面级错误显示
使用 AppEmptyState 显示错误和重试按钮：
```dart
error: (error, stack) => AppEmptyState(
  icon: '❌',
  title: '加载失败',
  subtitle: error.toString(),
  actionLabel: '重试',
  onAction: () => ref.invalidate(xxxProvider),
)
```

#### 3. 操作级错误 SnackBar
在各种操作中捕获异常并显示：
```dart
try {
  await someOperation();
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('操作失败: $e'),
        action: SnackBarAction(
          label: '重试',
          onPressed: () => retryOperation(),
        ),
      ),
    );
  }
}
```

### 修改文件
1. `lib/main.dart` - 添加 ProviderObserver
2. 各页面添加错误状态显示

---

## 五、Phase 6.4：删除撤销

### 实现方案

#### 1. 创建撤销服务
文件：`lib/core/services/undo_service.dart`

```dart
class UndoService {
  static final UndoService _instance = UndoService._internal();
  factory UndoService() => _instance;
  UndoService._internal();

  final Map<String, SoftDeleteItem> _pendingDeletes = {};

  // 暂存删除项
  Future<void> softDelete({
    required String id,
    required DeleteType type,
    required Future<void> Function() onConfirm,
    required Future<void> Function() onUndo,
  }) async {
    // 显示 SnackBar
    // 5 秒后执行确认删除
    // 如果用户点击撤销，执行取消删除
  }
}
```

#### 2. 在删除操作中集成
在 `family_management_page.dart`、`category_management_page.dart` 等页面的删除操作中：
```dart
void _deleteCategory(Category category) async {
  final db = ref.read(databaseProvider);
  
  // 先显示 SnackBar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('已删除「${category.name}」'),
      action: SnackBarAction(
        label: '撤销',
        onPressed: () {
          // 恢复数据
          ref.invalidate(categoriesProvider);
        },
      ),
      duration: const Duration(seconds: 5),
    ),
  );

  // 延迟执行真正删除
  Future.delayed(const Duration(seconds: 5), () {
    // 执行真正删除
  });
}
```

### 创建/修改文件
1. `lib/core/services/undo_service.dart` - 新建
2. `lib/presentation/profile/category_management_page.dart` - 集成撤销
3. `lib/presentation/profile/family_management_page.dart` - 集成撤销
4. 其他有删除操作的页面

---

## 六、Phase 6.5：动画 & 微交互

### 实现方案

#### 1. 页面转场动画
文件：`lib/core/router/app_router.dart`

```dart
GoRoute(
  // Tab 切换：渐隐渐显 200ms
  pageBuilder: (context, state) => CustomTransitionPage(
    child: SomePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: Duration(milliseconds: 200),
  ),
)

// Push 新页面：从右侧滑入 300ms
MaterialPage(
  child: SomePage(),
  // GoRouter 默认就是从右滑入，保持 300ms
)
```

#### 2. 按钮按下缩放动画
文件：`lib/presentation/common/widgets/app_button.dart`

```dart
class AppButton extends StatefulWidget {
  // ...
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 200),
        child: // ... button content
      ),
    );
  }
}
```

#### 3. 卡片按下缩放动画
在 `item_card.dart`、`location_card.dart` 等卡片组件中：

```dart
return GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedScale(
    scale: _isPressed ? 0.98 : 1.0,
    duration: Duration(milliseconds: 200),
    child: // ... card content
  ),
);
```

#### 4. 数字变化动画
在 `stat_card.dart` 中使用 AnimatedSwitcher：

```dart
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  child: Text(
    '$count',
    key: ValueKey(count),
    style: // ... style
  ),
)
```

#### 5. 下拉刷新
在 `home_page.dart` 和 `item_list_page.dart` 中使用 RefreshIndicator。

### 修改文件
1. `lib/core/router/app_router.dart` - 添加转场动画
2. `lib/presentation/common/widgets/app_button.dart` - 按钮动画
3. `lib/presentation/items/widgets/item_card.dart` - 卡片动画
4. `lib/presentation/home/widgets/stat_card.dart` - 数字动画
5. `lib/presentation/home/home_page.dart` - 下拉刷新

---

## 七、Phase 6.6：首次使用引导

### 实现方案

#### 1. 创建引导页
文件：`lib/presentation/onboarding/onboarding_page.dart`

```dart
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 3 步引导
  final List<Widget> _pages = [
    WelcomeStep(),
    RoomSelectStep(),
    FirstItemStep(),
  ];
}
```

#### 2. Step 1: 欢迎页
```dart
class WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🏠', style: TextStyle(fontSize: 80)),
        SizedBox(height: 24),
        Text('欢迎使用 HomeStock',
            style: Theme.of(context).textTheme.headlineMedium),
        Text('轻松管理家庭物品，再也不担心过期浪费'),
        SizedBox(height: 48),
        AppButton(
          label: '开始设置',
          onPressed: () => // 下一页
        ),
      ],
    );
  }
}
```

#### 3. Step 2: 房间选择
```dart
class RoomSelectStep extends StatefulWidget {
  @override
  State<RoomSelectStep> createState() => _RoomSelectStepState();
}

class _RoomSelectStepState extends State<RoomSelectStep> {
  final Set<String> _selectedRooms = {};

  final _presetRooms = ['客厅', '卧室', '厨房', '卫生间', '书房', '阳台'];

  // 选择后写入数据库
  Future<void> _saveRooms() async {
    // 调用 database_provider 写入位置数据
  }
}
```

#### 4. Step 3: 第一件物品
```dart
class FirstItemStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('📦', style: TextStyle(fontSize: 80)),
        SizedBox(height: 24),
        Text('试着添加第一件物品'),
        SizedBox(height: 48),
        AppButton(
          label: '扫码添加',
          onPressed: () => context.push('/items/scan'),
        ),
        SizedBox(height: 16),
        AppButton(
          label: '手动添加',
          onPressed: () => context.push('/items/add'),
        ),
        SizedBox(height: 16),
        TextButton(
          label: '跳过',
          onPressed: () => // 完成引导
        ),
      ],
    );
  }
}
```

#### 5. 判断首次启动
文件：`lib/main.dart`

```dart
// 修改启动逻辑
Future<void> checkFirstLaunch() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

  if (isFirstLaunch) {
    // 显示引导页
    runApp(ProviderScope(
      child: MaterialApp(
        home: OnboardingPage(
          onComplete: () async {
            await prefs.setBool('is_first_launch', false);
            // 重启应用
          },
        ),
      ),
    ));
  } else {
    // 正常启动
    runApp(ProviderScope(
      child: MyApp(),
    ));
  }
}
```

### 创建/修改文件
1. `lib/presentation/onboarding/onboarding_page.dart` - 新建
2. `lib/presentation/onboarding/widgets/welcome_step.dart` - 新建
3. `lib/presentation/onboarding/widgets/room_select_step.dart` - 新建
4. `lib/presentation/onboarding/widgets/first_item_step.dart` - 新建
5. `lib/main.dart` - 判断首次启动

---

## 八、Phase 6.7：性能优化

### 实现方案

#### 1. 物品列表懒加载
文件：`lib/presentation/items/item_list_page.dart`

- 使用 `ListView.builder` 替代普通 ListView
- 当物品数量 > 100 时实现分页（每页 20 条）
- 滚动到底部时加载更多

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    // 滚动到接近底部时预加载更多
    if (index == items.length - 5) {
      loadMore();
    }
    return ItemCard(...);
  },
)
```

#### 2. 位置详情页优化
文件：`lib/presentation/locations/location_detail_page.dart`

- 使用 `ListView.builder` 优化物品列表
- 减少 FutureBuilder 嵌套

### 修改文件
1. `lib/presentation/items/item_list_page.dart` - 列表优化
2. `lib/presentation/locations/location_detail_page.dart` - 优化

---

## 九、Phase 6.8：细节完善

### 实现方案

#### 1. 数字输入框格式验证
在 `add_item_page.dart` 和 `edit_item_page.dart` 中：
```dart
TextFormField(
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
  ],
)
```

#### 2. 日期选择器默认值
```dart
// 购买日期默认今天
final purchaseDate = DateTime.now();

// 过期日期默认未来一段时间（根据类别）
final defaultExpiry = DateTime.now().add(Duration(days: 365));
```

#### 3. 表单退出未保存提示
使用 `WillPopScope` 或 `PopScope`：
```dart
PopScope(
  canPop: !_hasUnsavedChanges,
  onPopInvokedWithResult: (didPop, result) {
    if (!didPop && _hasUnsavedChanges) {
      _showDiscardDialog();
    }
  },
)
```

#### 4. 列表滚动到顶部按钮
在 `item_list_page.dart` 等长列表页面添加：
```dart
FloatingActionButton(
  onPressed: () => _scrollController.animateTo(0),
  child: Icon(Icons.vertical_align_top),
)
```

#### 5. 数据一致性处理
- 物品删除时，关联的 `usage_records` 一并删除
- 物品删除时，`shopping_list` 中 `related_item_id` 对应项标记为无关联
- 位置删除时，该位置下物品的 `location_id` 置为 null

### 修改文件
1. `lib/presentation/items/add_item_page.dart` - 输入验证、日期默认值
2. `lib/presentation/items/edit_item_page.dart` - 输入验证
3. `lib/core/providers/database_provider.dart` - 数据一致性处理

---

## 十、实施顺序

1. Phase 6.1 - 空状态设计（简单，先做）
2. Phase 6.2 - 骨架屏加载（组件创建）
3. Phase 6.3 - 错误处理（基础设施）
4. Phase 6.4 - 删除撤销（用户体验）
5. Phase 6.5 - 动画 & 微交互（用户体验）
6. Phase 6.6 - 首次使用引导（独立模块）
7. Phase 6.7 - 性能优化（技术优化）
8. Phase 6.8 - 细节完善（收尾）

---

## 十一、验收标准

遵循 Phase 6 文档中的验收标准：

1. ✅ 所有空状态页面显示友好提示和引导操作
2. ✅ 数据加载时显示骨架屏而非空白或转圈
3. ✅ 操作失败有错误提示和重试选项
4. ✅ 删除后 5 秒内可撤销
5. ✅ 页面转场有平滑动画
6. ✅ 数字变化有过渡动画
7. ✅ 按钮/卡片有触摸反馈
8. ✅ 首次使用引导流程完整可走通
9. ✅ 引导选择的房间正确写入数据库
10. ✅ 100+ 物品时列表滚动流畅无卡顿
11. ✅ 表单退出有未保存提示
12. ✅ 数据删除时关联数据正确清理
13. ✅ 整体使用感受流畅、无明显 bug
