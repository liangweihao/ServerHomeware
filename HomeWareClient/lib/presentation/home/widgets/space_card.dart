import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/database/app_database.dart';
import '../../../core/theme/cartoon_palette.dart';
import '../../common/widgets/cartoon_pressable.dart';
import '../../common/widgets/cartoon_ui.dart';

/// 首页空间卡片 — 贴纸 emoji + 数量标签
class SpaceCard extends StatelessWidget {
  final Location location;
  final int itemCount;
  final VoidCallback? onTap;
  final int cartoonIndex;

  const SpaceCard({
    super.key,
    required this.location,
    required this.itemCount,
    this.onTap,
    this.cartoonIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final (fill, border) = CartoonPalette.pairAt(cartoonIndex);

    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryLighter,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Text(
            location.icon ?? '📦',
            style: const TextStyle(fontSize: 20, height: 1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          location.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.15,
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        CartoonStickerBadge(
          label: '$itemCount 件',
          accentColor: border,
          fillColor: fill,
          fontSize: 9,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        ),
      ],
    );

    return CartoonPressable(
      onTap: onTap,
      child: SizedBox(
        width: 116,
        child: AppSurface(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          fillColor: fill,
          borderColor: border,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxH =
                  constraints.maxHeight.isFinite ? constraints.maxHeight : 120.0;
              return SizedBox(
                height: maxH,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: body,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
