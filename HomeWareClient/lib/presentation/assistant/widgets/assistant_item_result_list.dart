import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assistant/assistant_models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';

/// 助手回复中的物品结果列表
class AssistantItemResultList extends StatelessWidget {
  const AssistantItemResultList({
    super.key,
    required this.items,
  });

  final List<AssistantItemSummary> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
      child: Column(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InkWell(
                  onTap: () {
                    debugPrint('[AssistantItemResultList] INFO: 打开物品 ${item.itemId}');
                    context.push('/items/${item.itemId}');
                  },
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.homeDivider),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
