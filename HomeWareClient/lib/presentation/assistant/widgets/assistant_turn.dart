import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assistant/assistant_suggestion_filter.dart';
import '../../../core/assistant/assistant_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_typography.dart';
import '../../common/widgets/guanguan_mascot_avatar.dart';
import 'assistant_chat_theme.dart';
import 'assistant_item_result_list.dart';
import 'assistant_message_body.dart';
import 'assistant_message_bubble.dart';

/// 一轮对话 — 用户单气泡 / 管管头像 + 气泡 + 物品卡片 + 操作按钮
class AssistantTurn extends StatelessWidget {
  const AssistantTurn({
    super.key,
    required this.message,
    this.onSuggestionTap,
  });

  final AssistantChatMessage message;

  /// 点击管管 `**建议词**` 时自动追问
  final ValueChanged<String>? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AssistantChatTheme.turnSpacing),
        child: AssistantMessageBubble(
          message: message,
          onSuggestionTap: onSuggestionTap,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AssistantChatTheme.turnSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: GuanguanMascotAvatar(size: AssistantChatTheme.mascotSize),
          ),
          const SizedBox(width: AssistantChatTheme.avatarGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AssistantMessageBubble(
                  message: message,
                  showAvatar: false,
                  onSuggestionTap: onSuggestionTap,
                ),
                if (message.items.isNotEmpty)
                  AssistantItemResultList(items: message.items),
                if (!message.isUser &&
                    onSuggestionTap != null &&
                    AssistantMessageBody.extractSuggestions(message.text)
                        .isNotEmpty)
                  _SuggestionQuickReplies(
                    suggestions: AssistantMessageBody.extractSuggestions(
                      message.text,
                    ),
                    onTap: (name) => onSuggestionTap!(
                      AssistantSuggestionFilter.tapQuery(name),
                    ),
                  ),
                if (message.actionRoute != null) _ActionPill(message: message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 管管回复中的 `**建议词**` — 快捷 Pill（与正文内联点击等效）
class _SuggestionQuickReplies extends StatelessWidget {
  const _SuggestionQuickReplies({
    required this.suggestions,
    required this.onTap,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final word in suggestions)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint(
                    '[AssistantTurn] INFO: 快捷追问 keyword=$word',
                  );
                  onTap(word);
                },
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  child: Text(
                    word,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 管管引导操作 — 圆润 Pill 按钮
class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.message});

  final AssistantChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          elevation: 0,
          shadowColor: AppColors.accentCoral.withValues(alpha: 0.12),
          child: InkWell(
            onTap: () {
              debugPrint(
                '[AssistantTurn] INFO: 跳转 ${message.actionRoute}',
              );
              context.push(message.actionRoute!);
            },
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                color: AppColors.primaryLighter,
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.45),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    message.actionLabel ?? '去确认',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
