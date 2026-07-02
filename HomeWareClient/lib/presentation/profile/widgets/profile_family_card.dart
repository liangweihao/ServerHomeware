import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/auth_service.dart';
import '../../common/widgets/app_button.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/app_section_header.dart';

/// 家庭信息卡 — 成员头像叠放 + 邀请码
class ProfileFamilyCard extends StatelessWidget {
  const ProfileFamilyCard({
    super.key,
    required this.familyName,
    required this.members,
    required this.itemCount,
    required this.inviteCode,
    this.loading = false,
    this.networkError = false,
    this.onRetry,
    this.onCreateFamily,
    this.onJoinFamily,
    this.onCopyInvite,
    this.onRefreshInvite,
    this.onManageMembers,
    this.onSwitchFamily,
  });

  final String? familyName;
  final List<dynamic> members;
  final int itemCount;
  final String inviteCode;
  final bool loading;
  final bool networkError;
  final VoidCallback? onRetry;
  final VoidCallback? onCreateFamily;
  final VoidCallback? onJoinFamily;
  final VoidCallback? onCopyInvite;
  final VoidCallback? onRefreshInvite;
  final VoidCallback? onManageMembers;
  final VoidCallback? onSwitchFamily;

  bool get _hasFamily => familyName != null;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (networkError) {
      return AppCard(
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 36, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text('家庭信息加载失败', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('请检查网络后重试', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            AppButton(
              label: '重新加载',
              onPressed: onRetry,
              variant: ButtonVariant.primary,
              size: ButtonSize.small32,
            ),
          ],
        ),
      );
    }

    if (!_hasFamily) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSectionHeader(title: '我的家庭'),
            const SizedBox(height: 8),
            Text(
              '还没有加入家庭',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            const Text(
              '邀请家人一起管理物品吧',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: '创建家庭',
                    onPressed: onCreateFamily,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.small32,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: '加入家庭',
                    onPressed: onJoinFamily,
                    variant: ButtonVariant.outline,
                    size: ButtonSize.small32,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: AppSectionHeader(title: '我的家庭')),
              if (onSwitchFamily != null)
                TextButton(
                  onPressed: () {
                    debugPrint('[ProfileFamilyCard] INFO: 切换家庭');
                    onSwitchFamily!();
                  },
                  child: const Text('切换'),
                ),
            ],
          ),
          Text(
            familyName!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(
                min(members.length, 5),
                (i) => _MemberAvatar(member: members[i]),
              ),
              if (members.length > 5)
                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gray100,
                    border: Border.all(color: AppColors.homeDivider),
                  ),
                  child: Center(
                    child: Text(
                      '+${members.length - 5}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '${members.length} 位成员 · $itemCount 件物品',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.homeDivider),
            ),
            child: Row(
              children: [
                Icon(Icons.key_outlined, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '邀请码',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  inviteCode.isNotEmpty ? inviteCode : '暂无',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: inviteCode.isEmpty
                      ? null
                      : () async {
                          debugPrint('[ProfileFamilyCard] INFO: 复制邀请码');
                          await Clipboard.setData(
                            ClipboardData(text: inviteCode),
                          );
                          onCopyInvite?.call();
                        },
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('复制'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRefreshInvite,
                  icon: const Icon(Icons.refresh_outlined, size: 16),
                  label: const Text('刷新'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (onManageMembers != null) ...[
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () {
                debugPrint('[ProfileFamilyCard] INFO: 管理成员');
                onManageMembers!();
              },
              icon: const Icon(Icons.people_outline, size: 18),
              label: const Text('管理家庭成员'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final dynamic member;

  @override
  Widget build(BuildContext context) {
    final name = member['nickname'] ?? member['phone'] ?? '?';
    final displayChar =
        name is String && name.isNotEmpty ? name[0].toUpperCase() : '?';
    final index = name.hashCode.abs() % 10;
    final colors = AuthService.getAvatarColors(index);

    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(colors[0]), Color(colors[1])],
        ),
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Center(
        child: Text(
          displayChar,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
