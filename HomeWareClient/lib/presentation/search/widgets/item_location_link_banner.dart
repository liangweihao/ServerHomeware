import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/search_constants.dart';

/// 搜索词 → 空间物品列表快捷入口
class ItemLocationLinkBanner extends StatelessWidget {
  const ItemLocationLinkBanner({super.key, required this.query});

  final String query;

  String? get _matchedLocation {
    final q = query.trim();
    if (q.isEmpty) return null;
    for (final loc in SearchConstants.spaceKeywords) {
      if (q.contains(loc)) return loc;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final location = _matchedLocation;
    if (location == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            debugPrint('[ItemLocationLink] INFO: 查看 $location 物品');
            context.push(
              '/items?location=${Uri.encodeComponent(location)}',
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.place_outlined, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '查看「$location」存放的物品',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primaryDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
