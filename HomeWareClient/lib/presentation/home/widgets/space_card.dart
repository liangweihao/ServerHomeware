import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../data/database/app_database.dart';

class SpaceCard extends StatelessWidget {
  final Location location;
  final int itemCount;
  final VoidCallback? onTap;

  const SpaceCard({
    super.key,
    required this.location,
    required this.itemCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location.icon ?? '📦',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              location.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$itemCount 件物品',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
