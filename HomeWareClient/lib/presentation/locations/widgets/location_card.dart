import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';
import '../../common/widgets/cartoon_pressable.dart';
import '../../common/widgets/cartoon_ui.dart';

/// 位置卡片 — 贴纸 emoji + 数量标签
class LocationCard extends StatelessWidget {
  final String name;
  final String? icon;
  final int itemCount;
  final bool isClickable;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDelete;
  final int cartoonIndex;

  const LocationCard({
    super.key,
    required this.name,
    this.icon,
    this.itemCount = 0,
    this.isClickable = true,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.showDelete = false,
    this.cartoonIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final (fill, border) = CartoonPalette.pairAt(cartoonIndex);

    final inner = Stack(
      children: [
        if (showDelete && onDelete != null)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
              onPressed: onDelete,
            ),
          ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary, width: 2.5),
              ),
              child: Text(icon ?? '🏠', style: const TextStyle(fontSize: 26, height: 1)),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            CartoonStickerBadge(
              label: '📦 $itemCount 件',
              accentColor: border,
              fillColor: fill,
              fontSize: 10,
            ),
          ],
        ),
      ],
    );

    return CartoonPressable(
      onTap: isClickable ? onTap : null,
      child: AppSurface(
        padding: const EdgeInsets.all(16),
        fillColor: isSelected ? AppColors.primaryLighter : fill,
        borderColor: isSelected ? AppColors.primaryDark : border,
        child: inner,
      ),
    );
  }
}
