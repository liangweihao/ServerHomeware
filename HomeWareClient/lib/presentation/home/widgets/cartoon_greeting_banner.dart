import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_decorations.dart';
import '../../../core/theme/app_decorations.dart';
import '../../common/widgets/cartoon_pressable.dart';
import '../../common/widgets/cartoon_mascot.dart';

/// ??????? ? ??? + ????
class CartoonGreetingBanner extends StatelessWidget {
  const CartoonGreetingBanner({super.key, this.familyName});

  final String? familyName;

  @override
  Widget build(BuildContext context) {
    final greeting = familyName != null && familyName!.isNotEmpty
        ? '?? ??$familyName ??'
        : '?? ??????';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CartoonPressable(
            onTap: null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 88, 14),
              decoration: CartoonDecorations.stickerCard(
                fillColor: AppColors.primaryLighter,
                borderColor: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '????????? ?',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppDecorations.cartoonAccentYellow
                          .withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppDecorations.cartoonAccentYellow,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '???????',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            right: 8,
            bottom: -4,
            child: CartoonMascot(size: 80),
          ),
        ],
      ),
    );
  }
}
