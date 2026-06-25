import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_visual_style.dart';
import '../../../core/theme/cartoon_decorations.dart';
import '../../../core/theme/cartoon_motion.dart';
import '../../common/widgets/cartoon_pressable.dart';

/// 卡通主题 — 浮动圆角 Dock 底栏（贴纸描边 + 弹性 Tab）
class CartoonBottomNav extends StatelessWidget {
  const CartoonBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.alertCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int alertCount;

  static const _animDuration = CartoonMotion.tabSlideDuration;
  static const _animCurve = CartoonMotion.tabSlideCurve;
  static const contentHeight = 68.0;
  static const horizontalMargin = 16.0;
  static const bottomMargin = 10.0;

  /// 底栏占用总高度（含安全区），供 Scaffold 预留留白
  static double totalHeight(BuildContext context) {
    return contentHeight +
        bottomMargin +
        MediaQuery.paddingOf(context).bottom;
  }

  static const _tabs = [
    _TabData(
      outlineAsset: 'assets/icons/home_outline.svg',
      filledAsset: 'assets/icons/home_filled.svg',
      label: '首页',
      emoji: '🏠',
    ),
    _TabData(
      outlineAsset: 'assets/icons/items_outline.svg',
      filledAsset: 'assets/icons/items_filled.svg',
      label: '物品',
      emoji: '📦',
    ),
    _TabData(
      outlineAsset: 'assets/icons/alerts_outline.svg',
      filledAsset: 'assets/icons/alerts_filled.svg',
      label: '提醒',
      emoji: '🔔',
    ),
    _TabData(
      outlineAsset: 'assets/icons/profile_outline.svg',
      filledAsset: 'assets/icons/profile_filled.svg',
      label: '我的',
      emoji: '😊',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        bottomInset + bottomMargin,
      ),
      child: DecoratedBox(
        decoration: CartoonDecorations.stickerCard(
          fillColor: AppColors.white,
          borderColor: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(28),
          shadowLevel: CartoonShadowLevel.floating,
        ),
        child: SizedBox(
          height: contentHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabCount = _tabs.length;
              final tabWidth = constraints.maxWidth / tabCount;
              const inset = 10.0;
              final pillWidth = tabWidth - inset * 2;
              final pillLeft = currentIndex * tabWidth + inset;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: _animDuration,
                    curve: _animCurve,
                    left: pillLeft,
                    top: 10,
                    bottom: 10,
                    width: pillWidth,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary,
                          width: CartoonDecorations.borderWidth,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(tabCount, (index) {
                      return Expanded(
                        child: _CartoonNavSlot(
                          tab: _tabs[index],
                          selected: currentIndex == index,
                          showBadge: index == 2 && alertCount > 0,
                          badgeCount: alertCount,
                          onTap: () {
                            if (currentIndex == index) return;
                            debugPrint(
                              '[CartoonBottomNav] 切换 Tab: '
                              '${_tabs[index].label} (index=$index)',
                            );
                            onTap(index);
                          },
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TabData {
  const _TabData({
    required this.outlineAsset,
    required this.filledAsset,
    required this.label,
    required this.emoji,
  });

  final String outlineAsset;
  final String filledAsset;
  final String label;
  final String emoji;
}

class _CartoonNavSlot extends StatelessWidget {
  const _CartoonNavSlot({
    required this.tab,
    required this.selected,
    required this.showBadge,
    required this.badgeCount,
    required this.onTap,
  });

  final _TabData tab;
  final bool selected;
  final bool showBadge;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CartoonPressable(
      onTap: onTap,
      child: Semantics(
        button: true,
        selected: selected,
        label: tab.label,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: selected ? 1.0 : 0.0),
            duration: CartoonBottomNav._animDuration,
            curve: CartoonBottomNav._animCurve,
            builder: (context, t, _) {
              final color = Color.lerp(
                AppColors.textHint,
                AppColors.primaryDark,
                t,
              )!;

              Widget iconWidget = selected
                  ? Text(
                      tab.emoji,
                      style: TextStyle(fontSize: 22 + t * 4, height: 1),
                    )
                  : SvgPicture.asset(
                      tab.outlineAsset,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    );

              if (showBadge) {
                iconWidget = Badge(
                  label: Text('$badgeCount'),
                  isLabelVisible: badgeCount > 0,
                  backgroundColor: AppColors.primary,
                  child: iconWidget,
                );
              }

              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: selected ? 1.0 + t * 0.15 : 1.0,
                      child: iconWidget,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.1,
                        fontWeight:
                            t > 0.5 ? FontWeight.w800 : FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
