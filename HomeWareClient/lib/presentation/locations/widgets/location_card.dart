import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class LocationCard extends StatelessWidget {
  final String name;
  final String? icon;
  final int itemCount;
  final bool isClickable;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDelete;

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
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
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
                Text(
                  icon ?? '🏠',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount 件物品',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
