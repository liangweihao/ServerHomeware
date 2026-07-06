import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/assistant_mascot.dart';
import '../../../core/models/space_type.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/services/guanguan_panel_prefs.dart';

/// P1-B — 全部待办清空时的每日结算条（每天最多展示一次）
class GuanguanDailySettlementBanner extends ConsumerStatefulWidget {
  const GuanguanDailySettlementBanner({super.key, required this.allClear});

  final bool allClear;

  @override
  ConsumerState<GuanguanDailySettlementBanner> createState() =>
      _GuanguanDailySettlementBannerState();
}

class _GuanguanDailySettlementBannerState
    extends ConsumerState<GuanguanDailySettlementBanner> {
  bool _visible = false;
  bool _checked = false;

  @override
  void didUpdateWidget(GuanguanDailySettlementBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allClear && !oldWidget.allClear) {
      _checked = false;
      _evaluate();
    }
  }

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    if (!widget.allClear) {
      if (mounted) setState(() => _visible = false);
      return;
    }
    final shown = await GuanguanPanelPrefs.hasShownSettlementToday();
    if (!mounted) return;
    setState(() {
      _checked = true;
      _visible = !shown;
    });
    if (!shown) {
      debugPrint('[GuanguanDailySettlement] INFO: 展示每日结算');
      await GuanguanPanelPrefs.markSettlementShownToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    if (!_checked || !_visible || !widget.allClear) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CandyIcon(Icons.celebration_outlined, color: AppColors.success, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AssistantMascot.name}：${skin.dailyAllClear}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      skin.spaceType == SpaceType.shop
                          ? '今日断货危机已化解'
                          : '今日厨房危机已化解',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: CandyIcon(Icons.close, size: 18, color: AppColors.textHint),
                onPressed: () => setState(() => _visible = false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
