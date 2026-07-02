import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'cartoon_tab_bar.dart';

/// Tab 项定义
class AppTabItem {
  const AppTabItem({required this.label, this.emoji});

  final String label;
  final String? emoji;
}

/// 主题感知 TabBar — 工具风 segmented / 卡通 segmented
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<AppTabItem> tabs;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    if (!AppColors.isUtilityStyle) {
      return CartoonTabBar(
        controller: controller,
        tabs: tabs
            .map((t) => CartoonTabItem(label: t.label, emoji: t.emoji))
            .toList(),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.homeDivider),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabW = constraints.maxWidth / tabs.length;
                final left = controller.index * tabW;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      left: left,
                      top: 0,
                      bottom: 0,
                      width: tabW,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(tabs.length, (i) {
                        final selected = controller.index == i;
                        final tab = tabs[i];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => controller.animateTo(i),
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (tab.emoji != null) ...[
                                      Text(
                                        tab.emoji!,
                                        style: TextStyle(
                                          fontSize: selected ? 14 : 12,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                    ],
                                    Text(
                                      tab.label,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? AppColors.primaryDark
                                            : AppColors.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
