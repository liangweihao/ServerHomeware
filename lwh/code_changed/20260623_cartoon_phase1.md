# 卡通主题第一期 —「像卡通」体验

## 技术开发文档

### 目标
在已有「卡通轻插画」换肤基础上，补齐第一期交互与视觉一致性，让用户切换主题后能明显感受到「卡通感」。

### 实现方案

#### 1. 动效与交互核心
- `lib/core/theme/cartoon_motion.dart` — 按压缩放、Tab 滑动、空状态入场的时长与曲线常量
- `lib/presentation/common/widgets/cartoon_pressable.dart` — 卡通主题下按压缩放 0.95 + 松开 `elasticOut` 回弹
- `lib/presentation/common/widgets/cartoon_fab.dart` — 圆角矩形 FAB + 贴纸阴影 + 弹性按压

#### 2. 文案与空状态
- `lib/core/theme/cartoon_copy.dart` — `CartoonEmptyKind` 枚举 + 温暖口语化空状态文案
- `assets/illustrations/` — 5 张 SVG 占位插画（物品/搜索/提醒/家庭/错误）
- `lib/presentation/common/widgets/cartoon_empty_illustration.dart` — 弹性入场 SVG 展示
- `AppEmptyState` 新增 `cartoonKind` / `searchQuery`，卡通主题下自动替换插画与文案

#### 3. 字体
- 依赖 `google_fonts`，卡通主题应用 **Nunito** 圆体（`app_theme.dart`）

#### 4. 组件接入
| 组件 | 改动 |
|------|------|
| `StatCard` | `CartoonPressable` 包裹 |
| `ItemCard` | 卡通 `AppSurface` + `CartoonPressable`，圆角缩略图/标签 |
| `AlertCard` | 卡通 `AppSurface` + 圆角图标底 |
| `CartoonBottomNav` | Tab 指示器 `elasticOut`，Tab 槽位 `CartoonPressable` |
| `AppButton` | 大圆角 + 主色描边 + 弹性按压 |
| `ProfilePage` 设置项 | `CartoonPressable` 替代 InkWell |
| `ItemListPage` | 空状态插画 + `CartoonFloatingActionButton` |

### 影响范围
- 仅 `AppVisualStyle.cartoon` 生效；其他三主题行为不变
- 新增网络字体依赖（首次加载需联网下载 Nunito，离线时 google_fonts 有回退）

---

## 提测开发文档

### 验证步骤
1. **我的 → 主题样式 → 卡通轻插画**
2. **首页**：统计卡片按压有缩放回弹；字体为圆体
3. **物品 Tab**：空列表见 SVG 箱子插画 + 温暖文案；FAB 圆角矩形 + 按压反馈
4. **提醒 Tab**：空列表见笑脸 SVG +「一切安好！」
5. **我的**：设置行点击有按压动画；卡片仍为贴纸边框风格
6. **切回其他主题**：确认无 CartoonPressable 副作用、空状态恢复 emoji

### 测试点
- [ ] ItemCard 列表滚动与点击跳转正常
- [ ] 底栏 Tab 切换指示器弹性滑动
- [ ] 搜索无结果时 search 插画与「没找到 xxx」文案
- [ ] 加载失败页 error 插画与「再试一次」按钮
- [ ] Android / Windows 构建通过（需 `flutter pub get`）

### 注意事项
- 执行 `flutter pub get` 安装 `google_fonts`
- SVG 为轻量占位风，后续可替换设计师稿
