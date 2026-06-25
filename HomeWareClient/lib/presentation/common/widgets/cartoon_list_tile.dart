import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';
import 'cartoon_pressable.dart';

/// 卡通列表行 �?通知/成员/分类等通用�?
class CartoonListTile extends StatelessWidget {
  const CartoonListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingEmoji,
    this.leadingIcon,
    this.leadingColor,
    this.onTap,
    this.colorIndex = 0,
    this.minHeight = 56,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? leadingEmoji;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final VoidCallback? onTap;
  final int colorIndex;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final accent = leadingColor ?? AppColors.primary;
    final (fill, border) = CartoonPalette.pairAt(colorIndex);

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeading(accent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else
          Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: 20,
          ),
      ],
    );

    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: row,
      ),
    );

    return CartoonPressable(
      onTap: onTap,
      child: AppSurface(
        fillColor: fill,
        borderColor: border,
        child: content,
      ),
    );
  }

  Widget _buildLeading(Color accent) {
    if (leadingEmoji != null) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent, width: 2),
        ),
        child: Text(leadingEmoji!, style: const TextStyle(fontSize: 20, height: 1)),
      );
    }

    if (leadingIcon != null) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent, width: 2),
        ),
        child: Icon(leadingIcon, size: 20, color: accent),
      );
    }

    return const SizedBox.shrink();
  }
}
