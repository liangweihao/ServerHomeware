import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../../core/theme/cartoon_copy.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/cartoon_fab.dart';
import '../common/widgets/cartoon_list_entrance.dart';
import '../common/widgets/cartoon_list_tile.dart';
import '../common/widgets/cartoon_scaffold.dart';

// Provider for family members
final familyMembersProvider = FutureProvider<List<FamilyMember>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getFamilyMembers();
});

class FamilyManagementPage extends ConsumerWidget {
  const FamilyManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(familyMembersProvider);

    return CartoonScaffold(
      title: '家庭成员',
      titleEmoji: '👨‍👩‍👧‍👦',
      body: membersAsync.when(
        data: (members) {
          if (members.isEmpty) {
            return AppEmptyState(
              icon: '👨‍👩‍👧‍👦',
              title: '暂无成员',
              subtitle: '添加家庭成员来记录使用者',
              actionLabel: '添加成员',
              cartoonKind: CartoonEmptyKind.family,
              onAction: () => _showAddMemberDialog(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return CartoonListEntrance(
                index: index,
                child: _buildMemberItem(context, ref, member, index),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppEmptyState(
          icon: '❌',
          title: '加载失败',
          subtitle: error.toString(),
        ),
      ),
      floatingActionButton: CartoonFloatingActionButton(
        onPressed: () => _showAddMemberDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context,
    WidgetRef ref,
    FamilyMember member,
    int index,
  ) {
    final leadingEmoji = member.name.isNotEmpty ? member.name[0] : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CartoonListTile(
        title: member.name,
        subtitle: _getRoleText(member.role),
        leadingEmoji: leadingEmoji,
        colorIndex: index,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditMemberDialog(context, ref, member);
            } else if (value == 'delete') {
              _deleteMember(context, ref, member);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
        onTap: () => _showEditMemberDialog(context, ref, member),
      ),
    );
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return '管理员';
      case 'member':
        return '成员';
      default:
        return '成员';
    }
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedRole = 'member';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加成员'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '成员名称',
                  hintText: '请输入成员名称',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: '角色',
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('管理员')),
                  DropdownMenuItem(value: 'member', child: Text('成员')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final db = ref.read(databaseProvider);
                await db.into(db.familyMembers).insert(
                  FamilyMembersCompanion.insert(
                    name: nameController.text.trim(),
                    role: drift.Value(selectedRole),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(familyMembersProvider);
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMemberDialog(BuildContext context, WidgetRef ref, FamilyMember member) {
    final nameController = TextEditingController(text: member.name);
    String selectedRole = member.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑成员'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '成员名称',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: '角色',
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('管理员')),
                  DropdownMenuItem(value: 'member', child: Text('成员')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final db = ref.read(databaseProvider);
                await (db.update(db.familyMembers)..where((m) => m.id.equals(member.id))).write(
                  FamilyMembersCompanion(
                    name: drift.Value(nameController.text.trim()),
                    role: drift.Value(selectedRole),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(familyMembersProvider);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMember(BuildContext context, WidgetRef ref, FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除成员'),
        content: Text('确定删除 "${member.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.delete(db.familyMembers)..where((m) => m.id.equals(member.id))).go();

              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(familyMembersProvider);
              }
            },
            child: const Text('删除', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
