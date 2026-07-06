import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/space_skin_config.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/guanguan_celebration_snackbar.dart';
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

  String _label(SpaceSkinConfig skin) =>
      skin.consumeQuickLabel(unit: widget.item.unit);

  Future<void> _onTap(SpaceSkinConfig skin) async {
    if (_busy || !_canConsume) return;
    setState(() => _busy = true);
    debugPrint('[QuickConsumeButton] INFO: 一键消耗 itemId=${widget.item.id}');
    try {
      final item = widget.item;
      final ok = await recordQuickUsage(ref: ref, item: item);
      if (!mounted || !ok) return;
      widget.onCompleted();
      final remaining = (item.currentQuantity - 1).clamp(0.0, double.infinity);
      GuanguanCelebrationSnackBar.show(
        context,
        message: skin.celebrateConsume(
          itemName: item.name,
          depleted: remaining <= 0,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    return AppButton(
      label: _label(skin),
      size: widget.size,
      isFullWidth: widget.fullWidth,
      isLoading: _busy,
      leadingIcon: const CandyIcon(Icons.remove_circle_outline, size: 20),
      onPressed: _canConsume && !_busy ? () => _onTap(skin) : null,
    );
  }
}
