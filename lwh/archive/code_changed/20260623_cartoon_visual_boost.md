# 卡通主题视觉加强 — 贴纸质感升级

## 背景
第一期仅加了轻量按压动效与细描边，用户反馈「仍然感受不到卡通风」。本次针对**视觉识别度**做加强，核心从「换色 + 细边框」升级为「贴纸漫画质感」。

## 改动点

### 1. 贴纸硬阴影体系
- 新增 `cartoon_decorations.dart`：`stickerShadows`（4px 硬偏移、零模糊）、`stickerCard`、`CartoonDotGridPainter`、`CartoonCloud`
- `AppDecorations.surface(cartoon)` 改为 **3px 深珊瑚描边 + 硬阴影**

### 2. 背景场景化
- `AppThemeBackground`：点阵底纹 + 手绘风云朵（替代原先半透明圆 blob）

### 3. 首页卡通化
- `CartoonGreetingBanner` — 「嗨～xxx 的家 / 今天也要好好整理哦 ✨」
- `CartoonSectionTitle` — 贴纸标签式区块标题（emoji + 粗体）
- `StatCard` — 纵向大数字 + 图标气泡硬阴影
- `SpaceCard` / `TodayAlertBanner` / 动态列表 — 统一贴纸卡片
- 统计 Grid `childAspectRatio` 调整为 `0.92`（适配纵向卡）

### 4. 底栏与 FAB
- `CartoonBottomNav` — 顶栏硬阴影、选中 Tab 指示器贴纸化、图标选中放大
- `CartoonFloatingActionButton` — 深描边 + 4px 硬阴影

### 5. 字体
- Nunito 标题/正文整体加粗（w700~w900）

## 提测
1. 切换 **卡通轻插画** 主题
2. 首页应明显看到：点阵背景、问候贴纸、区块标签、统计大数字卡
3. 底栏 Tab 切换时指示器弹性 + 图标略放大
4. 物品 FAB 为圆角矩形硬阴影
5. 切回其他主题无回归

## 后续可选
- 列表入场 stagger 动画
- 更多页面统一 `CartoonSectionTitle`
- 设计师稿替换 SVG 云朵/插画
