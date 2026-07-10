import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/assistant/assistant_models.dart';
import 'assistant_chat_theme.dart';
import 'assistant_message_body.dart';

/// 助手 / 用户 气泡（管管侧由 [AssistantTurn] 提供头像）
class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.onSuggestionTap,
  });

  final AssistantChatMessage message;

  /// 是否在气泡内嵌头像（旧布局兼容；问管管页传 false）
  final bool showAvatar;

  /// 点击管管回复中 `**建议词**` 时触发（自动追问）
  final ValueChanged<String>? onSuggestionTap;

  void _copyMessage(BuildContext context) {
    final plain = AssistantMessageBody.plainText(message.text);
    Clipboard.setData(ClipboardData(text: plain));
    debugPrint('[AssistantMessageBubble] INFO: 复制消息 len=${plain.length}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已复制到剪贴板'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _showMessageMenu(BuildContext context, Offset globalPosition) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(Icons.copy_rounded, size: 20, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Text('复制'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'copy' && context.mounted) {
        _copyMessage(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxWidth = MediaQuery.sizeOf(context).width * (isUser ? 0.78 : 0.88);

    final body = AssistantMessageBody(
      text: message.text,
      baseStyle: isUser
          ? AssistantChatTheme.userBody
          : AssistantChatTheme.assistantBody,
      enableSuggestionTap: !isUser,
      onSuggestionTap: onSuggestionTap,
    );

    final bubble = GestureDetector(
      onLongPressStart: (details) {
        _showMessageMenu(context, details.globalPosition);
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(
          horizontal: isUser ? 16 : 15,
          vertical: isUser ? 11 : 12,
        ),
        decoration: isUser
            ? AssistantChatTheme.userBubbleDecoration
            : AssistantChatTheme.assistantBubbleDecoration,
        child: body,
      ),
    );

    if (isUser) {
      return Align(alignment: Alignment.centerRight, child: bubble);
    }

    return Align(alignment: Alignment.centerLeft, child: bubble);
  }
}
