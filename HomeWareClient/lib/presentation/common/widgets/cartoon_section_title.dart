import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_decorations.dart';
import 'cartoon_pressable.dart';

/// ???? ? ???? + emoji + ????
class CartoonSectionTitle extends StatelessWidget {
  const CartoonSectionTitle({
    super.key,
    required this.title,
    this.emoji,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? emoji;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Transform.rotate(
            angle: -0.02,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: CartoonDecorations.stickerCard(
                fillColor: AppColors.primaryLighter,
                borderColor: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                shadowLevel: CartoonShadowLevel.none,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (emoji != null) ...[
                    Text(emoji!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (actionLabel != null && onAction != null)
            CartoonPressable(
              onTap: onAction,
              scale: 0.92,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: CartoonDecorations.stickerCard(
                  fillColor: AppColors.white,
                  borderColor: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  shadowLevel: CartoonShadowLevel.none,
                ),
                child: Text(
                  '$actionLabel ?',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
