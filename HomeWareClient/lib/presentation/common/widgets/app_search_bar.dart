import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final String? placeholder;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.placeholder,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.disabled.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: TextField(
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          hintText: placeholder ?? '搜索',
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
