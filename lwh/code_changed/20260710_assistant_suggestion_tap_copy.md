# 问管管 — 建议词点击追问 & 消息复制

## 需求

1. 管管回复中 `**羊肉**`、`**猪肉**` 等建议词可点击，自动作为用户消息发送继续对话
2. 长按气泡支持复制消息内容

## 实现

| 文件 | 改动 |
|------|------|
| `assistant_message_body.dart` | 解析 `**词**`；管管侧加 TapGestureRecognizer；`plainText` / `extractSuggestions` |
| `assistant_message_bubble.dart` | 长按弹出「复制」菜单；剪贴板 + SnackBar |
| `assistant_turn.dart` | 传递 `onSuggestionTap`；气泡下快捷 Pill |
| `assistant_chat_page.dart` | `onSuggestionTap: _send` |

## 交互

- **内联点击**：`**羊肉**` 显示珊瑚色下划线，点击 → `_send('羊肉')`
- **快捷 Pill**：同条消息下方展示「羊肉」「猪肉」圆角按钮（与内联等效）
- **复制**：长按任意用户/管管气泡 → 选「复制」→ 去掉 `**` 的纯文本

## 提测

1. 问「胖肉在哪」类误输入，管管回复含 `**羊肉**` `**猪肉**`
2. 点击内联词或下方 Pill → 自动发送并收到新回复
3. 长按气泡 → 复制 → 粘贴验证无 `**` 标记
