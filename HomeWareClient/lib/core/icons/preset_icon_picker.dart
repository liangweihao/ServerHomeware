import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import 'app_icon.dart';
import 'preset_icon_registry.dart';

/// 预置图标选择网格 — 分类/空间添加对话框共用
class PresetIconPickerGrid extends StatelessWidget {
  const PresetIconPickerGrid({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onSelected,
    this.crossAxisCount = 6,
  });

  final List<PresetIconOption> options;
  final String selectedKey;
  final ValueChanged<String> onSelected;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = option.storageKey == selectedKey;
        return InkWell(
          onTap: () => onSelected(option.storageKey),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
              color: selected ? AppColors.primaryLighter : AppColors.white,
            ),
            alignment: Alignment.center,
            child: AppIcon.feature(
              icon: option.icon,
              accent: option.accent,
              wellSize: 36,
              iconSize: 18,
            ),
          ),
        );
      },
    );
  }
}

/// Wrap 布局的紧凑选择器（分类管理对话框）
class PresetIconPickerWrap extends StatelessWidget {
  const PresetIconPickerWrap({
    super.key,
    required this.options,
    required this.selectedKey,
    required this.onSelected,
  });

  final List<PresetIconOption> options;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = option.storageKey == selectedKey;
        return InkWell(
          onTap: () => onSelected(option.storageKey),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
              color: selected ? AppColors.primaryLighter : AppColors.white,
            ),
            alignment: Alignment.center,
            child: AppIcon.feature(
              icon: option.icon,
              accent: option.accent,
              wellSize: 34,
              iconSize: 17,
            ),
          ),
        );
      }).toList(),
    );
  }
}
