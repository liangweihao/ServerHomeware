import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';

/// 通用骨架屏加载组件
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// 骨架屏列表项（模拟 ItemCard）
class ShimmerItemCard extends StatelessWidget {
  const ShimmerItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 图片占位
          const ShimmerLoading(width: 56, height: 56, borderRadius: 8),
          const SizedBox(width: 12),
          // 文字占位
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 16,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: 12,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 12,
                  borderRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 右侧数量占位
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerLoading(width: 40, height: 16, borderRadius: 4),
              const SizedBox(height: 8),
              ShimmerLoading(width: 50, height: 20, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

/// 骨架屏统计卡片（布局与 [StatCard] 一致：白底 + 左侧色条）
class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShimmerLoading(width: 4, height: 88, borderRadius: 0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ShimmerLoading(width: 18, height: 18, borderRadius: 4),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ShimmerLoading(
                            width: MediaQuery.sizeOf(context).width * 0.2,
                            height: 12,
                            borderRadius: 4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const ShimmerLoading(width: 56, height: 20, borderRadius: 4),
                    const SizedBox(height: 2),
                    const ShimmerLoading(width: 72, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 骨架屏空间卡片
class ShimmerSpaceCard extends StatelessWidget {
  const ShimmerSpaceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerLoading(width: 32, height: 32, borderRadius: 8),
          const SizedBox(height: 12),
          ShimmerLoading(width: 80, height: 16, borderRadius: 4),
          const SizedBox(height: 8),
          ShimmerLoading(width: 50, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

/// 骨架屏动态项
class ShimmerActivityItem extends StatelessWidget {
  const ShimmerActivityItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          ShimmerLoading(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(width: 100, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                ShimmerLoading(width: 60, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 通知中心列表项骨架屏
class ShimmerNotificationTile extends StatelessWidget {
  const ShimmerNotificationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(width: 22, height: 22, borderRadius: 4),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(width: 180, height: 12, borderRadius: 4),
                const SizedBox(height: 6),
                ShimmerLoading(width: 120, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
