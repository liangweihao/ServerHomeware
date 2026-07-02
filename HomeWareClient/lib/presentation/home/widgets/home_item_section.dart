import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_constants.dart';
import '../../../core/models/home_section.dart';
import 'home_section_header.dart';
import 'home_two_row_scroll_grid.dart';

/// 首页单个分区：头部 + 双排横向滑动卡片网格
class HomeItemSection extends StatelessWidget {
  const HomeItemSection({
    super.key,
    required this.section,
  });

  final HomeSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        border: AppColors.isUtilityStyle
            ? Border(
                bottom: BorderSide(color: AppColors.homeDivider, width: 0.5),
              )
            : null,
      ),
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(
            config: section.config,
            itemCount: section.items.length,
            onViewAll: () {
              debugPrint(
                '[HomeItemSection] INFO: 查看全部 ${section.config.routeSection}',
              );
              context.push('/home/section/${section.config.routeSection}');
            },
          ),
          const SizedBox(height: 12),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (section.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HomeConstants.horizontalPadding,
        ),
        child: Text(
          '加载失败：${section.errorMessage}',
          style: TextStyle(color: AppColors.danger, fontSize: 13),
        ),
      );
    }

    if (section.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HomeConstants.horizontalPadding,
        ),
        child: Text(
          '暂无${section.config.title}物品',
          style: TextStyle(color: AppColors.textHint, fontSize: 13),
        ),
      );
    }

    return HomeTwoRowScrollGrid(items: section.items);
  }
}
