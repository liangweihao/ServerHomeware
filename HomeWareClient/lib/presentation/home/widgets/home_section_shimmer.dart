import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_constants.dart';
import '../../common/widgets/shimmer_loading.dart';

/// 首页分区骨架屏
class HomeSectionShimmer extends StatelessWidget {
  const HomeSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sectionBackground,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HomeConstants.horizontalPadding,
            ),
            child: ShimmerLoading(width: 80, height: 20, borderRadius: 6),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: HomeConstants.twoRowListHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: HomeConstants.horizontalPadding,
              ),
              itemCount: 2,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: HomeConstants.previewColumnSpacing),
              itemBuilder: (_, __) => Column(
                children: [
                  ShimmerLoading(
                    width: HomeConstants.cardWidth,
                    height: HomeConstants.horizontalListHeight - 8,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: HomeConstants.previewRowSpacing),
                  ShimmerLoading(
                    width: HomeConstants.cardWidth,
                    height: HomeConstants.horizontalListHeight - 8,
                    borderRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
