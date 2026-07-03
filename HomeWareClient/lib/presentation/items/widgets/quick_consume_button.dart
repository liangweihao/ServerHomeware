import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';
import 'usage_dialog.dart';

/// 一键消耗 — M2 家庭场景：默认减 1，无需弹窗
class QuickConsumeButton extends ConsumerStatefulWidget {
  const QuickConsumeButton({
    super.key,
    required this.item,
    required this.onCompleted,
    this.size = ButtonSize.large48,
    this.fullWidth = true,
  });

  final Item item;
  final VoidCallback onCompleted;
  final ButtonSize size;
  final bool fullWidth;

  @override
  ConsumerState<QuickConsumeButton> createState() => _QuickConsumeButtonState();
}

class _QuickConsumeButtonState extends ConsumerState<QuickConsumeButton> {
  bool _busy = false;

  bool get _canConsume =>
      widget.item.status == 0 && widget.item.currentQuantity > 0;

  String get _label {
    final unit = widget.item.unit;
    if (unit.isNotEmpty) return '用了 1 $unit';
    return '用了 1 件';
  }

  Future<void> _onTap() async {
    if (_busy || !_canConsume) return;
    setState(() => _busy = true);
    debugPrint('[QuickConsumeButton] INFO: 一键消耗 itemId=${widget.item.id}');
    try {
      final item = widget.item;
      final ok = await recordQuickUsage(ref: ref, item: item);
      if (!mounted || !ok) return;
      widget.onCompleted();
      final remaining = (item.currentQuantity - 1).clamp(0.0, double.infinity);
      final unit = item.unit;
      final msg = remaining > 0
          ? '已用 1 $unit，还剩 ${_formatQty(remaining)} $unit'
          : '「${item.name}」已用完';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _formatQty(double v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _label,
      size: widget.size,
      isFullWidth: widget.fullWidth,
      isLoading: _busy,
      leadingIcon: const Icon(Icons.remove_circle_outline, size: 20),
      onPressed: _canConsume && !_busy ? _onTap : null,
    );
  }
}
