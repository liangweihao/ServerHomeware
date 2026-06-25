import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';
import '../../common/widgets/cartoon_pressable.dart';

/// ?????? ? emoji ?? + ????
class StatCard extends StatelessWidget {
  final IconData icon;
  /// ?????????????
  final Color accentColor;
  final String title;
  final String count;
  final String? subtitle;
  final VoidCallback? onTap;
  /// ?????????0?3 ???
  final int cartoonIndex;

  const StatCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.count,
    this.subtitle,
    this.onTap,
    this.cartoonIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final (fill, border) = CartoonPalette.pairForAccent(accentColor);
    final emoji = CartoonPalette.emojiFor(icon);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: 2.5),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24, height: 1),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.05,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    final card = CartoonPressable(
      onTap: onTap,
      child: AppSurface(
        fillColor: fill,
        borderColor: border,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ?????????FittedBox ????? scaleDown
                return SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: content,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    return Transform.rotate(
      angle: CartoonPalette.tiltAt(cartoonIndex),
      child: card,
    );
  }
}
