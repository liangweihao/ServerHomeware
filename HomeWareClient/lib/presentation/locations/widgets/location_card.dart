import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';
import '../../common/widgets/cartoon_pressable.dart';
import '../../common/widgets/cartoon_ui.dart';
import '../../common/widgets/tag_chip.dart';

/// 位置卡片 — 工具风白底轻阴影 / 卡通贴纸双分支
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
    if (AppColors.isUtilityStyle) {
      return _buildUtilityCard(context);
    }
    return _buildCartoonCard(context);
  }

  /// 工具风 — 白卡片 + TagChip 数量
  Widget _buildUtilityCard(BuildContext context) {
    final borderColor =
        isSelected ? AppColors.primary : AppColors.homeDivider;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: isSelected ? 2 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              if (showDelete && onDelete != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.danger, size: 20),
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
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      icon ?? '🏠',
                      style: const TextStyle(fontSize: 24, height: 1),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  TagChip(
                    label: '$itemCount 件',
                    color: AppColors.textSecondary,
                    background: AppColors.gray100,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 卡通风 — 贴纸色块 + CartoonStickerBadge
  Widget _buildCartoonCard(BuildContext context) {
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
              label: '$itemCount 件',
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
