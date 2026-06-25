import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/cartoon_decorations.dart';
import 'cartoon_pressable.dart';

/// Tab ? ? ?????? + ?????
class CartoonTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CartoonTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<CartoonTabItem> tabs;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: CartoonDecorations.stickerCard(
              fillColor: AppColors.white,
              borderColor: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              shadowLevel: CartoonShadowLevel.none,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabW = constraints.maxWidth / tabs.length;
                final left = controller.index * tabW;

                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.elasticOut,
                      left: left,
                      top: 0,
                      bottom: 0,
                      width: tabW,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLighter,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(tabs.length, (i) {
                        final selected = controller.index == i;
                        final tab = tabs[i];
                        return Expanded(
                          child: CartoonPressable(
                            onTap: () => controller.animateTo(i),
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
                                        fontSize: 12,
                                        fontWeight: selected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
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

/// Tab ?
class CartoonTabItem {
  const CartoonTabItem({required this.label, this.emoji});

  final String label;
  final String? emoji;
}
