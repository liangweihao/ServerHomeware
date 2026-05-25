import 'package:flutter/material.dart';
import '../../common/widgets/shimmer_loading.dart';

/// 首页骨架屏
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索栏骨架屏
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),

          // "需要关注" 标题
          const ShimmerLoading(width: 80, height: 20, borderRadius: 4),
          const SizedBox(height: 12),

          // 统计卡片网格
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: const [
              ShimmerStatCard(),
              ShimmerStatCard(),
              ShimmerStatCard(),
              ShimmerStatCard(),
            ],
          ),
          const SizedBox(height: 24),

          // "快捷查看" 标题
          const ShimmerLoading(width: 80, height: 20, borderRadius: 4),
          const SizedBox(height: 12),

          // 空间卡片列表
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const ShimmerSpaceCard(),
            ),
          ),
          const SizedBox(height: 24),

          // "最近动态" 标题
          const ShimmerLoading(width: 80, height: 20, borderRadius: 4),
          const SizedBox(height: 12),

          // 动态列表骨架屏
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: List.generate(4, (index) => const ShimmerActivityItem()),
            ),
          ),
        ],
      ),
    );
  }
}

/// 物品列表骨架屏
class ItemListShimmer extends StatelessWidget {
  const ItemListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => const ShimmerItemCard(),
    );
  }
}
