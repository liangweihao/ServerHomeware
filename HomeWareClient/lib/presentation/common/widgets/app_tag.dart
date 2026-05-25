import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum TagVariant { defaultVariant, success, warning, danger, info }
enum TagSize { medium, small }

class AppTag extends StatelessWidget {
  final String label;
  final TagVariant variant;
  final TagSize size;

  const AppTag({
    super.key,
    required this.label,
    this.variant = TagVariant.defaultVariant,
    this.size = TagSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = size == TagSize.small ? 8 : 12;
    final double verticalPadding = size == TagSize.small ? 4 : 6;
    final TextStyle? textStyle = (size == TagSize.small
            ? Theme.of(context).textTheme.bodySmall
            : Theme.of(context).textTheme.bodyMedium)
        ?.copyWith(fontWeight: FontWeight.w500);

    final (Color bgColor, Color textColor) = switch (variant) {
      TagVariant.defaultVariant => (AppColors.disabled.withOpacity(0.2), AppColors.textSecondary),
      TagVariant.success => (AppColors.successLight, AppColors.success),
      TagVariant.warning => (AppColors.warningLight, AppColors.warning),
      TagVariant.danger => (AppColors.dangerLight, AppColors.danger),
      TagVariant.info => (AppColors.primary.withOpacity(0.1), AppColors.primary),
    };

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Text(
        label,
        style: textStyle?.copyWith(color: textColor),
      ),
    );
  }
}
