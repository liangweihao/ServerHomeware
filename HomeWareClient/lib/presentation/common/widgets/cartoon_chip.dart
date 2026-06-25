import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_decorations.dart';
import 'cartoon_pressable.dart';

/// ???? Chip ? ?? / ??
class CartoonChip extends StatelessWidget {
  const CartoonChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final fill = selected ? AppColors.primaryLighter : AppColors.white;
    final border = selected ? AppColors.primaryDark : AppColors.primaryLight;

    return CartoonPressable(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: CartoonDecorations.stickerCard(
          fillColor: fill,
          borderColor: border,
          borderRadius: BorderRadius.circular(16),
          shadowLevel: CartoonShadowLevel.none,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14, height: 1)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
