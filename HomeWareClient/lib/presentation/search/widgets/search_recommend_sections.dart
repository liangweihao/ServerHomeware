import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/home_section.dart';
import '../../home/providers/home_sections_provider.dart';
import '../../items/widgets/item_card.dart';

/// 搜索页推荐分区 — 仅物品（临期 / 最近入库）
class SearchRecommendSections extends ConsumerWidget {
  const SearchRecommendSections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeSectionsProvider);

    return homeAsync.when(
      data: (sections) {
        final blocks = <Widget>[];

        final expiring = _findSection(sections, HomeSectionType.expiringSoon);
        if (expiring != null && expiring.items.isNotEmpty) {
          blocks.add(
            _RecommendBlock(
              title: '即将过期',
              onViewAll: () => context.push('/home/section/expiring'),
              child: _horizontalItems(expiring.items),
            ),
          );
        }

        final recent = _findSection(sections, HomeSectionType.recentAll);
        if (recent != null && recent.items.isNotEmpty) {
          blocks.add(
            _RecommendBlock(
              title: '最近入库',
              onViewAll: () => context.push('/home/section/all'),
              child: _horizontalItems(recent.items),
            ),
          );
        }

        if (blocks.isEmpty) return const SizedBox.shrink();
        return Column(children: blocks);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  HomeSectionData? _findSection(
    List<HomeSectionData> sections,
    HomeSectionType type,
  ) {
    for (final s in sections) {
      if (s.config.type == type) return s;
    }
    return null;
  }

  Widget _horizontalItems(List<HomeSectionItem> items) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length.clamp(0, 6),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => ItemCard.feed(sectionItem: items[i]),
      ),
    );
  }
}

class _RecommendBlock extends StatelessWidget {
  const _RecommendBlock({
    required this.title,
    required this.onViewAll,
    required this.child,
  });

  final String title;
  final VoidCallback onViewAll;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('查看全部'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
