import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/home_constants.dart';
import '../../core/models/home_section.dart';
import '../common/widgets/app_empty_state.dart';
import 'providers/home_sections_provider.dart';
import '../items/widgets/item_card.dart';

/// 首页分区「查看全部」— 竖向完整列表
class HomeSectionListPage extends ConsumerWidget {
  const HomeSectionListPage({
    super.key,
    required this.section,
  });

  final String section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = homeSectionTitle(section);
    final listAsync = ref.watch(homeSectionFullListProvider(section));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const CandyIcon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: listAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return AppEmptyState(
              icon: '📦',
              title: '暂无$title物品',
              subtitle: '添加物品后会出现在这里',
              actionLabel: '添加入库',
              onAction: () => context.push('/items/add'),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(homeSectionFullListProvider(section));
              await ref.read(homeSectionFullListProvider(section).future);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(HomeConstants.horizontalPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemCard.feed(sectionItem: items[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          debugPrint('[HomeSectionListPage] ERROR: $error');
          return AppEmptyState(
            icon: '❌',
            title: '加载失败',
            subtitle: '$error',
            actionLabel: '重试',
            onAction: () =>
                ref.invalidate(homeSectionFullListProvider(section)),
          );
        },
      ),
    );
  }
}
