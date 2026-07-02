import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../common/widgets/app_card.dart';
import 'profile_fade_slide_in.dart';

/// 快捷功能 Bento 宫格 — 首行大卡 + 入场动效
class ProfileQuickActionGrid extends StatelessWidget {
  const ProfileQuickActionGrid({
    super.key,
    required this.actions,
  });

  final List<ProfileQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final featured = actions.where((a) => a.highlight).toList();
    final regular = actions.where((a) => !a.highlight).toList();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
      child: Column(
        children: [
          if (featured.isNotEmpty) ...[
            Row(
              children: [
                for (var i = 0; i < featured.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: ProfileFadeSlideIn(
                      delay: Duration(milliseconds: 80 * i),
                      child: _FeaturedCell(action: featured[i]),
                    ),
                  ),
                ],
              ],
            ),
            if (regular.isNotEmpty) const SizedBox(height: 10),
          ],
          if (regular.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: regular.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                return ProfileFadeSlideIn(
                  delay: Duration(milliseconds: 120 + index * 45),
                  child: _RegularCell(action: regular[index]),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 宫格长按快捷项
class ProfileQuickShortcut {
  const ProfileQuickShortcut({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

/// 宫格单项
class ProfileQuickAction {
  const ProfileQuickAction({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
    this.badge,
    this.highlight = false,
    this.subtitle,
    this.shortcuts,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color tint;
  final VoidCallback onTap;
  final int? badge;
  final bool highlight;
  final List<ProfileQuickShortcut>? shortcuts;
}

/// 长按弹出快捷操作 Sheet
void showProfileQuickShortcutsSheet(
  BuildContext context,
  ProfileQuickAction action,
) {
  final shortcuts = action.shortcuts;
  if (shortcuts == null || shortcuts.isEmpty) return;

  debugPrint('[ProfileQuickActionGrid] INFO: 长按 ${action.label} 快捷菜单');

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      final (wellBg, wellFg) =
                          AppColors.iconWellFor(action.tint);
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: wellBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(action.icon, color: wellFg, size: 20),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${action.label} · 快捷操作',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...shortcuts.map(
                (s) => ListTile(
                  leading: Icon(s.icon, color: action.tint),
                  title: Text(s.label),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    debugPrint(
                      '[ProfileQuickActionGrid] INFO: 快捷 ${action.label} → ${s.label}',
                    );
                    s.onTap();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _FeaturedCell extends StatelessWidget {
  const _FeaturedCell({required this.action});

  final ProfileQuickAction action;

  @override
  Widget build(BuildContext context) {
    final utility = AppColors.isUtilityStyle;
    final (wellBg, wellFg) = AppColors.iconWellFor(action.tint);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('[ProfileQuickActionGrid] INFO: ${action.label}');
          action.onTap();
        },
        onLongPress: action.shortcuts != null && action.shortcuts!.isNotEmpty
            ? () => showProfileQuickShortcutsSheet(context, action)
            : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 100,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: utility ? AppColors.gray50 : null,
              gradient: utility
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        action.tint.withValues(alpha: 0.18),
                        action.tint.withValues(alpha: 0.06),
                      ],
                    ),
              border: Border.all(
                color: utility
                    ? AppColors.homeDivider
                    : action.tint.withValues(alpha: 0.25),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                if (!utility)
                  Positioned(
                    right: -8,
                    bottom: -8,
                    child: Icon(
                      action.icon,
                      size: 56,
                      color: action.tint.withValues(alpha: 0.1),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: wellBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              action.icon,
                              color: wellFg,
                              size: 20,
                            ),
                          ),
                          const Spacer(),
                          if (action.badge != null && action.badge! > 0)
                            _Badge(count: action.badge!),
                        ],
                      ),
                      Text(
                        action.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (action.subtitle != null)
                        Text(
                          action.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.2,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegularCell extends StatelessWidget {
  const _RegularCell({required this.action});

  final ProfileQuickAction action;

  @override
  Widget build(BuildContext context) {
    final utility = AppColors.isUtilityStyle;
    final (wellBg, wellFg) = AppColors.iconWellFor(action.tint);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('[ProfileQuickActionGrid] INFO: ${action.label}');
          action.onTap();
        },
        onLongPress: action.shortcuts != null && action.shortcuts!.isNotEmpty
            ? () => showProfileQuickShortcutsSheet(context, action)
            : null,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: wellBg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    action.icon,
                    size: 21,
                    color: wellFg,
                  ),
                ),
                if (action.badge != null && action.badge! > 0)
                  Positioned(top: -4, right: -6, child: _Badge(count: action.badge!)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.35),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
