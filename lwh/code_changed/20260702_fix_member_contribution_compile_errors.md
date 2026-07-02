# 修复成员贡献详情页编译错误

## 技术开发文档

### 问题

热重载/同步到设备时报错：

1. `member_contribution_detail_page.dart` import 路径错误，找不到 `family_contribution_provider.dart` 与 `warm_scaffold.dart`
2. `member_operation_type_chart.dart` 在 `static const` 列表中使用 `AppColors.info`、`AppColors.primary`（运行时 getter），导致常量求值失败

### 改动点

| 文件 | 改动 |
|------|------|
| `lib/presentation/profile/member_contribution_detail_page.dart` | 修正 import：`providers/...`、`../common/widgets/warm_scaffold.dart`（与同目录 `family_contribution_page.dart` 一致） |
| `lib/presentation/profile/widgets/member_operation_type_chart.dart` | `_colors` 由 `static const` 改为 `static final`，并补充注释说明原因 |

### 影响范围

- 成员贡献详情独立页可正常编译
- 操作类型饼图色板行为不变（仍随当前色板主题取色）

## 提测开发文档

### 测试点

1. 从家庭贡献页进入成员贡献详情页，页面正常展示标题与内容
2. 成员详情中的「操作类型分布」饼图正常渲染，图例颜色与扇区一致
3. 热重载 / 全量重启无编译错误

### 验证方式

```powershell
cd HomeWareClient
flutter run
# 或仅分析相关文件
flutter analyze lib/presentation/profile/member_contribution_detail_page.dart lib/presentation/profile/widgets/member_operation_type_chart.dart
```

### 注意事项

- `AppColors` 中 `primary`、`info` 等为 `static Color get`，不可用于 `const` 表达式；仅 `success`、`danger`、`warning`、`textSecondary` 等为 `static const`
