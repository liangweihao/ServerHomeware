import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/icons/preset_icon.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_constants.dart';
import '../../../core/providers/home_provider.dart';

/// 首页「按空间」横滑分区 — 数据来自 location API / 本地 DB
class HomeSpaceSection extends ConsumerWidget {
  const HomeSpaceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(spacesProvider);

    return spacesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) {
        debugPrint('[HomeSpaceSection] WARN: 空间加载失败 $e');
        return const SizedBox.shrink();
      },
      data: (spaces) {
        if (spaces.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HomeConstants.horizontalPadding,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A7A52).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const CandyIcon(
                      Icons.home_outlined,
                      size: 20,
                      color: Color(0xFF5A7A52),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '按空间',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '快速浏览各房间物品',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      debugPrint('[HomeSpaceSection] INFO: 查看全部 → 空间总览');
                      context.push('/locations');
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('查看全部', style: TextStyle(fontSize: 14)),
                        CandyIcon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: spaces.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final space = spaces[index];
                  return _SpaceTile(
                    name: space.location.name,
                    icon: space.location.icon ?? '📦',
                    itemCount: space.itemCount,
                    onTap: () {
                      debugPrint(
                        '[HomeSpaceSection] INFO: 进入场景 ${space.location.name}',
                      );
                      context.push('/locations/${space.location.id}');
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SpaceTile extends StatelessWidget {
  const _SpaceTile({
    required this.name,
    required this.icon,
    required this.itemCount,
    required this.onTap,
  });

  final String name;
  final String icon;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.homeDivider),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PresetIcon(
                storageKey: icon,
                name: name,
                wellSize: 32,
                iconSize: 16,
              ),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              Text(
                '$itemCount 件',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
