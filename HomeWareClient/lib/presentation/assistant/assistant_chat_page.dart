import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/assistant/assistant_item_resolver.dart';
import '../../core/assistant/assistant_chat_storage.dart';
import '../../core/assistant/assistant_executor.dart';
import '../../core/assistant/assistant_models.dart';
import '../../core/config/space_skin_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../common/widgets/warm_scaffold.dart';
import 'widgets/assistant_mascot_header.dart';
import 'widgets/assistant_typing_indicator.dart';
import 'widgets/assistant_turn.dart';

/// 问管管 — 直连 LLM + 服务端对话历史（重装 App 可恢复）
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
  bool _historyLoaded = false;
  List<String> _lastSuggestions = SpaceSkinConfig.home.assistantSuggestions;
  AssistantExecutor? _executor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 从服务端加载历史记录
  Future<void> _loadHistory() async {
    final db = ref.read(databaseProvider);
    final skin = ref.read(spaceSkinProvider);
    final stored = await AssistantChatStorage.load();
    if (!mounted) return;

    // 历史 meta 中的 itemId 需与当前 Drift 对齐，保证可点击跳转
    final resolvedStored = <AssistantChatMessage>[];
    for (final msg in stored) {
      if (msg.isUser || msg.items.isEmpty) {
        resolvedStored.add(msg);
        continue;
      }
      final items = await AssistantItemResolver.resolve(db, msg.items);
      resolvedStored.add(
        AssistantChatMessage(
          isUser: msg.isUser,
          text: msg.text,
          items: items,
          actionLabel: msg.actionLabel,
          actionRoute: msg.actionRoute,
        ),
      );
    }

    setState(() {
      _historyLoaded = true;
      if (resolvedStored.isEmpty) {
        _messages.add(
          AssistantChatMessage(isUser: false, text: skin.welcomeMessage),
        );
      } else {
        _messages.addAll(resolvedStored);
      }
      _executor = AssistantExecutor(db: db, skin: skin);
      _lastSuggestions = skin.assistantSuggestions;
    });
    _scrollToBottom();
    debugPrint('[AssistantChatPage] INFO: 历史加载完成 messages=${_messages.length}');
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _busy || !_historyLoaded) return;

    final db = ref.read(databaseProvider);
    final skin = ref.read(spaceSkinProvider);
    final userMsg = AssistantChatMessage(isUser: true, text: trimmed);

    debugPrint('[AssistantChatPage] INFO: 用户提问 $trimmed');
    setState(() {
      _busy = true;
      _messages.add(userMsg);
      _controller.clear();
    });
    _scrollToBottom();

    try {
      _executor ??= AssistantExecutor(db: db, skin: skin);
      final reply = await _executor!.handle(trimmed);

      if (!mounted) return;
      debugPrint('[AssistantChatPage] INFO: 管管回复 >>> ${reply.text}');
      final assistantMsg = AssistantChatMessage(
        isUser: false,
        text: reply.text,
        items: reply.items,
        actionLabel: reply.actionLabel,
        actionRoute: reply.actionRoute,
      );

      setState(() {
        _messages.add(assistantMsg);
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

  /// 清空服务端对话历史
  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空对话'),
        content: const Text('确定清空与管管的所有聊天记录吗？清空后其他设备也会同步删除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('清空')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await AssistantChatStorage.clear();
    final db = ref.read(databaseProvider);
    final skin = ref.read(spaceSkinProvider);

    setState(() {
      _messages
        ..clear()
        ..add(AssistantChatMessage(isUser: false, text: skin.welcomeMessage));
      _executor = AssistantExecutor(db: db, skin: skin);
    });
    debugPrint('[AssistantChatPage] INFO: 用户清空服务端对话历史');
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
    return WarmScaffold(
      title: '问管管',
      actions: [
        if (_historyLoaded && _messages.length > 1)
          IconButton(
            tooltip: '清空对话',
            onPressed: _busy ? null : _clearHistory,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
      ],
      body: Column(
        children: [
          AssistantMascotHeader(isThinking: _busy),
          Expanded(
            child: !_historyLoaded
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                    itemCount: _messages.length + (_busy ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_busy && index == _messages.length) {
                        return const AssistantTypingIndicator();
                      }
                      return AssistantTurn(
                        message: _messages[index],
                        onSuggestionTap: _busy ? null : _send,
                      );
                    },
                  ),
          ),
          _SuggestionChips(
            suggestions: _lastSuggestions,
            onTap: _send,
            enabled: !_busy && _historyLoaded,
          ),
          _InputBar(
            controller: _controller,
            busy: _busy || !_historyLoaded,
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
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = suggestions[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? () => onTap(label) : null,
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Ink(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentCoral.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
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
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.gray700.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !busy,
                minLines: 1,
                maxLines: 4,
                style: AppTypography.bodyMedium,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: '想问什么？比如「羊肉在哪」',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide(
                      color: AppColors.primaryLight.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: busy ? AppColors.gray300 : AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              elevation: busy ? 0 : 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
              child: InkWell(
                onTap: busy ? null : onSend,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AppColors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
