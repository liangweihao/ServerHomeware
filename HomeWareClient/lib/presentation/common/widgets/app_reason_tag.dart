import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/item_list_reason_helper.dart';
import 'cartoon_ui.dart';
import 'tag_chip.dart';

/// 物品「出现理由」标签 — 工具风 TagChip / 卡通贴纸
class AppReasonTag extends StatelessWidget {
  AppReasonTag({
    super.key,
    required ItemListReason reason,
    this.compact = false,
  })  : _label = reason.label,
        _color = reason.color,
        _emoji = reason.emoji;

  /// 纯文本理由（无 ItemListReason 对象时）
  const AppReasonTag.plain({
    super.key,
    required String label,
    required Color color,
    String? emoji,
    this.compact = false,
  })  : _label = label,
        _color = color,
        _emoji = emoji ?? '';

  final String _label;
  final Color _color;
  final String _emoji;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isUtilityStyle) {
      return TagChip(
        label: _label,
        color: _color,
        background: AppColors.tagBackgroundFor(_color),
      );
    }

    return CartoonStickerBadge(
      emoji: _emoji.isEmpty ? null : _emoji,
      label: _label,
      accentColor: _color,
      fillColor: _color.withValues(alpha: 0.12),
      fontSize: compact ? 10 : 11,
      compact: compact,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 7, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    );
  }
}
