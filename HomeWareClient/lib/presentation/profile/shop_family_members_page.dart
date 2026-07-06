import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/shop_role_guard.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/family_provider.dart';
import '../../core/providers/family_role_provider.dart';
import '../../core/providers/space_skin_provider.dart';
import '../../core/services/family_service.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_list_row.dart';
import '../common/widgets/warm_scaffold.dart';

/// 店铺成员管理 — 老板可调整 clerk/admin/member 角色
class ShopFamilyMembersPage extends ConsumerWidget {
  const ShopFamilyMembersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(spaceSkinProvider);
    final role = ref.watch(familyRoleProvider);
    final familyAsync = ref.watch(currentFamilyProvider);

    if (!ShopRoleGuard.canChangeMemberRole(skin, role)) {
      return WarmScaffold(
        title: '成员与角色',
        body: const Center(
          child: Text('仅老板可管理成员角色'),
        ),
      );
    }

    return WarmScaffold(
      title: skin.orgLabel == '店铺' ? '店员与角色' : '成员与角色',
      body: familyAsync.when(
        data: (family) {
          final members = (family?['members'] as List?) ?? [];
          final familyId = family?['id'];
          if (familyId == null) {
            return const Center(child: Text('暂无家庭信息'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final m = members[index] as Map<String, dynamic>;
              return _MemberRoleTile(
                member: m,
                familyId: familyId is int ? familyId : int.parse('$familyId'),
                isShop: skin.showSalePrice,
                onChanged: () => ref.invalidate(currentFamilyProvider),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}

class _MemberRoleTile extends StatelessWidget {
  const _MemberRoleTile({
    required this.member,
    required this.familyId,
    required this.isShop,
    required this.onChanged,
  });

  final Map<String, dynamic> member;
  final int familyId;
  final bool isShop;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final userId = member['user_id'];
    final name = member['nickname'] ?? member['phone'] ?? '成员';
    final currentRole = member['role']?.toString() ?? 'member';
    final isOwner = currentRole == 'owner';

    return AppCard(
      padding: EdgeInsets.zero,
      child: AppListRow(
        leadingEmoji: name.toString().isNotEmpty ? name.toString()[0] : '?',
        title: name.toString(),
        subtitle: ShopRoleGuard.roleLabel(currentRole, isShop: isShop),
        showChevron: false,
        trailing: isOwner
            ? const Text('老板', style: TextStyle(color: AppColors.textHint))
            : DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _dropdownValue(currentRole),
                  items: [
                    for (final r in _assignableRoles())
                      DropdownMenuItem(
                        value: r,
                        child: Text(ShopRoleGuard.roleLabel(r, isShop: isShop)),
                      ),
                  ],
                  onChanged: (value) async {
                    if (value == null || userId == null) return;
                    final uid = userId is int ? userId : int.tryParse('$userId');
                    if (uid == null) return;
                    final result = await FamilyService().updateMemberRole(
                      familyId: familyId,
                      userId: uid,
                      role: value,
                    );
                    if (!context.mounted) return;
                    if (result.code == 200) {
                      debugPrint('[ShopFamilyMembersPage] INFO: 角色已更新 uid=$uid role=$value');
                      onChanged();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('角色已更新')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result.message)),
                      );
                    }
                  },
                ),
              ),
      ),
    );
  }

  List<String> _assignableRoles() {
    if (isShop) return ['admin', 'clerk', 'member'];
    return ['admin', 'member'];
  }

  String _dropdownValue(String role) {
    if (_assignableRoles().contains(role)) return role;
    return 'member';
  }
}
