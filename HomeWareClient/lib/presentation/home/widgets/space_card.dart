import 'package:flutter/material.dart';
import '../../../core/icons/preset_icon.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/database/app_database.dart';
import '../../../core/theme/cartoon_palette.dart';
import '../../common/widgets/cartoon_pressable.dart';
import '../../common/widgets/cartoon_ui.dart';
import '../../common/widgets/tag_chip.dart';

/// 首页空间卡片 — 工具风紧凑白卡 / 卡通贴纸双分支
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
    if (AppColors.isUtilityStyle) {
      return _buildUtilityCard(context);
    }
    return _buildCartoonCard(context);
  }

  /// 工具风 — 白底轻阴影，与 ItemCard Feed 一致
  Widget _buildUtilityCard(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                PresetIcon(
                  storageKey: location.icon,
                  name: location.name,
                  wellSize: 36,
                  iconSize: 18,
                ),
                const SizedBox(height: 6),
                Text(
                  location.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                TagChip(
                  label: '$itemCount 件',
                  color: AppColors.textSecondary,
                  background: AppColors.gray100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 卡通风 — 贴纸色块
  Widget _buildCartoonCard(BuildContext context) {
    final (fill, border) = CartoonPalette.pairAt(cartoonIndex);

    final body = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        PresetIcon(
          storageKey: location.icon,
          name: location.name,
          wellSize: 38,
          iconSize: 19,
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
