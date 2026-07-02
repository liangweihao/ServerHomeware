import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 横向筛选 Chip 条 — 点评/闲鱼式快速筛选
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return FilterChip(
            label: Text(
              labels[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
            selected: selected,
            showCheckmark: false,
            backgroundColor: AppColors.white,
            selectedColor: AppColors.primaryLighter,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.homeDivider,
            ),
            onSelected: (_) {
              debugPrint('[FilterChipBar] INFO: 选择筛选 ${labels[index]}');
              onSelected(index);
            },
          );
        },
      ),
    );
  }
}
