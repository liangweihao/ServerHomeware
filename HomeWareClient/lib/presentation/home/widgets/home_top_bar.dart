import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/home_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../common/widgets/guanguan_mascot_avatar.dart';

/// 首页固定顶栏：头像 | 搜索框 | 问管家 | 添加入口
class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: HomeConstants.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: HomeConstants.horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.homeDivider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _UserAvatarButton(ref: ref),
          const SizedBox(width: 12),
          const Expanded(child: _HomeSearchField()),
          const SizedBox(width: 8),
          const _AssistantEntryButton(),
          const SizedBox(width: 8),
          _AddItemButton(ref: ref),
        ],
      ),
    );
  }
}

class _UserAvatarButton extends StatelessWidget {
  const _UserAvatarButton({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider.notifier).currentUser;
    final avatarIndex = AuthService.getAvatarColorIndex(user?.phone ?? '');
    final colors = AuthService.getAvatarColors(avatarIndex);
    var displayChar = '?';
    if (user?.nickname != null && user!.nickname!.isNotEmpty) {
      displayChar = user.nickname![0].toUpperCase();
    } else if (user?.phone != null) {
      displayChar = user!.phone!.substring(user.phone!.length - 4);
    }

    return GestureDetector(
      onTap: () {
        debugPrint('[HomeTopBar] INFO: 打开个人中心');
        context.push('/profile/panel');
      },
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(colors[0]), Color(colors[1])],
            ),
          ),
          child: Center(
            child: Text(
              displayChar,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 搜索入口 — 点击跳转搜索页
class _HomeSearchField extends ConsumerWidget {
  const _HomeSearchField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hint = ref.watch(spaceSkinProvider).searchHint;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('[HomeTopBar] INFO: 打开搜索');
          context.push('/search');
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textHint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// 问管家入口 — Phase 1 端侧规则助手
class _AssistantEntryButton extends StatelessWidget {
  const _AssistantEntryButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('[HomeTopBar] INFO: 打开问管家');
          context.push('/assistant');
        },
        customBorder: const CircleBorder(),
          child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white,
            border: Border.all(color: AppColors.homeDivider),
          ),
          child: const Center(
            child: GuanguanMascotAvatar(
              size: 36,
              mode: GuanguanAvatarMode.icon,
            ),
          ),
        ),
      ),
    );
  }
}

/// 圆形添加入口
class _AddItemButton extends StatelessWidget {
  const _AddItemButton({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('[HomeTopBar] INFO: 打开录入方式选择');
          context.push('/items/add/method');
        },
        customBorder: const CircleBorder(),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentHighlight,
            boxShadow: AppColors.cardShadow,
          ),
          child: Icon(
            Icons.add,
            color: AppColors.onAccentHighlight,
            size: 24,
          ),
        ),
      ),
    );
  }
}
