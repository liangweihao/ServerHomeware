import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/assistant/assistant_executor.dart';
import '../../core/assistant/assistant_models.dart';
import '../../core/config/space_skin_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../common/widgets/warm_scaffold.dart';
import 'widgets/assistant_item_result_list.dart';
import 'widgets/assistant_mascot_header.dart';
import 'widgets/assistant_message_bubble.dart';

/// 问管管 — Phase 1 端侧规则对话（查本地库存）
class AssistantChatPage extends ConsumerStatefulWidget {
  const AssistantChatPage({super.key});

  @override
  ConsumerState<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends ConsumerState<AssistantChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <AssistantChatMessage>[];
  bool _busy = false;
  List<String> _lastSuggestions = SpaceSkinConfig.home.assistantSuggestions;
  bool _welcomeSeeded = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _busy) return;

    debugPrint('[AssistantChatPage] INFO: 用户提问 $trimmed');
    setState(() {
      _busy = true;
      _messages.add(AssistantChatMessage(isUser: true, text: trimmed));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final db = ref.read(databaseProvider);
      final skin = ref.read(spaceSkinProvider);
      final executor = AssistantExecutor(db, skin: skin);
      final reply = await executor.handle(trimmed);

      if (!mounted) return;
      setState(() {
        _messages.add(
          AssistantChatMessage(
            isUser: false,
            text: reply.text,
            items: reply.items,
            actionLabel: reply.actionLabel,
            actionRoute: reply.actionRoute,
          ),
        );
        if (reply.suggestions.isNotEmpty) {
          _lastSuggestions = reply.suggestions;
        }
        _busy = false;
      });
      _scrollToBottom();
    } catch (e, stack) {
      debugPrint('[AssistantChatPage] ERROR: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _messages.add(
          AssistantChatMessage(
            isUser: false,
            text: ref.read(spaceSkinProvider).queryError,
          ),
        );
        _busy = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    if (!_welcomeSeeded) {
      _welcomeSeeded = true;
      _lastSuggestions = skin.assistantSuggestions;
      _messages.add(
        AssistantChatMessage(isUser: false, text: skin.welcomeMessage),
      );
    }
    return WarmScaffold(
      title: '问管管',
      body: Column(
        children: [
          const AssistantMascotHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AssistantMessageBubble(message: msg),
                    if (!msg.isUser && msg.actionRoute != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton.tonalIcon(
                            onPressed: () {
                              debugPrint(
                                '[AssistantChatPage] INFO: 跳转 ${msg.actionRoute}',
                              );
                              context.push(msg.actionRoute!);
                            },
                            icon: const Icon(Icons.edit_note_outlined, size: 18),
                            label: Text(msg.actionLabel ?? '去确认'),
                          ),
                        ),
                      ),
                    if (!msg.isUser && msg.items.isNotEmpty)
                      AssistantItemResultList(items: msg.items),
                  ],
                );
              },
            ),
          ),
          _SuggestionChips(
            suggestions: _lastSuggestions,
            onTap: _send,
            enabled: !_busy,
          ),
          _InputBar(
            controller: _controller,
            busy: _busy,
            onSend: () => _send(_controller.text),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({
    required this.suggestions,
    required this.onTap,
    required this.enabled,
  });

  final List<String> suggestions;
  final ValueChanged<String> onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = suggestions[index];
          return ActionChip(
            label: Text(label, style: const TextStyle(fontSize: 12)),
            onPressed: enabled ? () => onTap(label) : null,
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.busy,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.homeDivider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !busy,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: '问管管：厨房有什么、牛奶在哪',
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: busy ? null : onSend,
              icon: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
