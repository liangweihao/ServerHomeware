import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/assistant/assistant_suggestion_filter.dart';
import '../../../core/constants/app_colors.dart';

/// 问管管消息正文 — 库存类 `**词**` 可点击追问；购物清单类仅加粗
class AssistantMessageBody extends StatefulWidget {
  const AssistantMessageBody({
    super.key,
    required this.text,
    required this.baseStyle,
    this.enableSuggestionTap = false,
    this.onSuggestionTap,
  });

  final String text;
  final TextStyle baseStyle;

  /// 管管回复中可点击库存追问
  final bool enableSuggestionTap;

  /// 点击建议词回调（已格式化为「X在哪里」）
  final ValueChanged<String>? onSuggestionTap;

  /// 去掉 Markdown 标记后的纯文本（复制剪贴板用）
  static String plainText(String raw) {
    return raw.replaceAll('**', '').trim();
  }

  /// 提取可点击的库存类加粗词（供 Pill 使用）
  static List<String> extractSuggestions(String raw) {
    return AssistantSuggestionFilter.extractActionable(raw);
  }

  @override
  State<AssistantMessageBody> createState() => _AssistantMessageBodyState();
}

class _AssistantMessageBodyState extends State<AssistantMessageBody> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    if (!widget.text.contains('**')) {
      return Text(widget.text, style: widget.baseStyle);
    }

    final spans = <InlineSpan>[];
    final parts = widget.text.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      final isBold = i.isOdd;
      final segment = parts[i];
      final actionable = isBold &&
          widget.enableSuggestionTap &&
          widget.onSuggestionTap != null &&
          AssistantSuggestionFilter.isActionable(segment);

      if (actionable) {
        final query = AssistantSuggestionFilter.tapQuery(segment);
        final recognizer = TapGestureRecognizer()
          ..onTap = () {
            debugPrint(
              '[AssistantMessageBody] INFO: 点击库存词 query=$query',
            );
            widget.onSuggestionTap!(query);
          };
        _recognizers.add(recognizer);
        spans.add(
          TextSpan(
            text: segment,
            style: widget.baseStyle.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primaryLight,
            ),
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: segment,
            style: isBold
                ? widget.baseStyle.copyWith(fontWeight: FontWeight.w800)
                : widget.baseStyle,
          ),
        );
      }
    }

    return Text.rich(TextSpan(children: spans, style: widget.baseStyle));
  }
}
