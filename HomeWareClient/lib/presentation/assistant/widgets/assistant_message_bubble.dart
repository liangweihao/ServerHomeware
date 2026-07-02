import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/assistant/assistant_models.dart';

/// 助手 / 用户 气泡
class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.message,
  });

  final AssistantChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadius.md),
            topRight: const Radius.circular(AppRadius.md),
            bottomLeft: Radius.circular(isUser ? AppRadius.md : AppRadius.sm),
            bottomRight: Radius.circular(isUser ? AppRadius.sm : AppRadius.md),
          ),
          border: isUser ? null : Border.all(color: AppColors.homeDivider),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: isUser ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
