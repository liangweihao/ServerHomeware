# 问管管 UI — Candy Light 亲和力优化

## 目标

统一问管管页气泡、物品卡片、建议 Chip、输入栏的视觉，更温暖圆润、家庭友好。

## 改动点

| 组件 | 优化 |
|------|------|
| `assistant_chat_theme.dart` | 新增共享 Token：气泡装饰、字体、`**加粗**` 解析 |
| `assistant_turn.dart` | 管管侧头像 + 气泡 + 卡片 + 操作 Pill 一轮布局 |
| `assistant_message_bubble.dart` | 珊瑚浅底 / 主色用户泡；AppTypography；无硬描边 |
| `assistant_item_result_list.dart` | 圆角卡片 + 珊瑚 iconWell + 「详情」引导 |
| `assistant_mascot_header.dart` | 渐变顶栏 + 更亲切副标题 |
| `assistant_typing_indicator.dart` | 与管管气泡同风格、对齐头像 |
| `assistant_chat_page.dart` | 建议 Chip 圆点 Pill；输入框 xl 圆角 + 阴影底栏 |

## 设计原则

- 管管气泡：`primaryLighter` 浅底 + 轻阴影（非白底描边）
- 用户气泡：主色 + 软阴影
- 卡片：白底 + `cardShadow`，无粗边框
- 字体：`AppTypography` 全链路，行高 1.5+

## 提测

1. 热重载进入问管管
2. 检查：顶栏渐变、对话头像对齐、物品卡片可点、建议 Chip 圆角
3. 含 `**十斤羊肉**` 的回复应显示加粗
