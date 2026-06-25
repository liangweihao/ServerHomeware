# 卡通主题第二期 — 视觉性格强化

## 改动摘要

在第一期贴纸质感基础上，进一步拉开与普通主题的视觉差距。

### 1. 马卡龙色 + 手贴倾斜
- `cartoon_palette.dart` —  pastel 色板、统计卡 tilt 角、Icon→emoji 映射
- `StatCard` — 每卡不同马卡龙底色（粉/黄/珊瑚/薄荷）、emoji 图标、轻微旋转
- `ItemCard` — 交替珊瑚/天蓝马卡龙底

### 2. 吉祥物与场景
- `assets/illustrations/mascot_box.svg` — 盒子小管家
- `CartoonMascot` — idle 上下弹跳动画
- 问候条右侧吉祥物 +「小管家已就绪～」标签
- 背景增加 `CartoonSparklePainter` 闪粉点缀

### 3. 浮动 Dock 底栏
- `CartoonBottomNav` — 左右留白圆角 Dock、选中 Tab 显示 emoji 图标并放大
- `MainScaffold` — `extendBody` + 底部留白适配浮动栏

### 4. 物品页
- 贴纸搜索框 + 卡通 hint
- `CartoonChip` 筛选标签
- `CartoonListEntrance` 列表错开入场

### 5. 个人中心
- 头像贴纸圆环 + 硬阴影

### 6. AppSurface 扩展
- 支持 `fillColor` / `borderColor` / `shadowColor` 自定义马卡龙卡片

## 提测
1. 切换卡通主题，看首页四宫格是否「彩色 + 略倾斜 + emoji」
2. 问候条右侧盒子吉祥物是否弹跳
3. 底栏是否为浮动圆角 Dock，选中 Tab 是否变 emoji
4. 物品列表：搜索框贴纸化、筛选 chip、列表入场动画
5. 我的：头像贴纸框

## 后续方向
- 全页面统一 `CartoonSectionTitle`
- 手绘风图标替换 Material Icon
- 页面转场 / 音效
