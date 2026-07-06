import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/icons/candy_icon.dart';
import '../../../core/icons/candy_icons.dart';
import '../../../core/icons/preset_icon.dart';
import '../../../core/services/family_service.dart';

/// 切换家庭底部弹窗组件
class SwitchFamilyBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> families;
  final String? currentFamilyId;
  final Map<String, dynamic>? currentFamilyData;
  final dynamic userId;

  const SwitchFamilyBottomSheet({
    super.key,
    required this.families,
    this.currentFamilyId,
    this.currentFamilyData,
    this.userId,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Map<String, dynamic>> families,
    String? currentFamilyId,
    Map<String, dynamic>? currentFamilyData,
    dynamic userId,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SwitchFamilyBottomSheet(
        families: families,
        currentFamilyId: currentFamilyId,
        currentFamilyData: currentFamilyData,
        userId: userId,
      ),
    );
  }

  @override
  State<SwitchFamilyBottomSheet> createState() => _SwitchFamilyBottomSheetState();
}

class _SwitchFamilyBottomSheetState extends State<SwitchFamilyBottomSheet> {
  bool _isLoading = false;
  String _loadingMessage = '处理中...';
  List<Map<String, dynamic>> _families = [];

  @override
  void initState() {
    super.initState();
    _families = List.from(widget.families);
  }

  String _familyId(Map<String, dynamic> family) =>
      (family['id'] as dynamic)?.toString() ?? '';

  String _familyRole(Map<String, dynamic> family) =>
      (family['role'] as String?) ?? 'member';

  /// owner / admin 可看到「更多」并编辑家庭
  bool _canManageFamily(String role) => role == 'owner' || role == 'admin';

  /// 仅 owner 可删除家庭
  bool _canDeleteFamily(String role) => role == 'owner';

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return '创建者';
      case 'admin':
        return '管理员';
      default:
        return '成员';
    }
  }

  int _memberCount(Map<String, dynamic> family) {
    final count = family['member_count'];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  int _itemCount(Map<String, dynamic> family) {
    final count = family['item_count'];
    if (count is int) return count;
    if (count is num) return count.toInt();
    return 0;
  }

  void _log(String message) {
    debugPrint('[SwitchFamilyBottomSheet] $message');
  }

  Future<void> _showMoreMenu(
    Map<String, dynamic> family,
    TapDownDetails details,
  ) async {
    final role = _familyRole(family);
    if (!_canManageFamily(role)) {
      _log('WARN: 无权限打开更多菜单 - role=$role');
      return;
    }

    final isLastFamily = _families.length <= 1;
    final canDelete = _canDeleteFamily(role);
    _log(
      'INFO: 打开更多菜单 - role=$role, canDelete=$canDelete, '
      'familyCount=${_families.length}, isLastFamily=$isLastFamily',
    );

    final overlayBox =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromLTWH(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
      Offset.zero & overlayBox.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              CandyIcon(CandyIcons.edit, size: 18, color: AppColors.gray700),
              SizedBox(width: 8),
              Text('编辑家庭'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          enabled: canDelete,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CandyIcon(
                    CandyIcons.deleteOutline,
                    size: 18,
                    color: canDelete ? AppColors.danger : AppColors.gray300,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '删除家庭',
                    style: TextStyle(
                      color: canDelete ? AppColors.danger : AppColors.gray300,
                    ),
                  ),
                ],
              ),
              if (canDelete && isLastFamily)
                const Padding(
                  padding: EdgeInsets.only(left: 26, top: 2),
                  child: Text(
                    '删除后需创建或加入新家庭',
                    style: TextStyle(fontSize: 11, color: AppColors.gray500),
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    if (!mounted || selected == null) return;

    if (selected == 'edit') {
      _showEditFamilyDialog(family);
    } else if (selected == 'delete') {
      if (!canDelete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('只有创建者可以删除家庭')),
        );
        return;
      }
      _showDeleteConfirmDialog(family);
    }
  }

  void _showEditFamilyDialog(Map<String, dynamic> family) {
    final familyId = _familyId(family);
    final role = _familyRole(family);
    if (!_canManageFamily(role)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('仅创建者或管理员可编辑家庭')),
      );
      return;
    }

    final controller = TextEditingController(text: family['name']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('编辑家庭'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(
            labelText: '家庭名称',
            hintText: '请输入家庭名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('家庭名称不能为空')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              await _handleUpdateFamily(familyId, name);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdateFamily(String familyId, String name) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = '保存中...';
    });

    try {
      _log('INFO: 更新家庭 - id=$familyId, name=$name');
      final service = FamilyService();
      final res = await service.updateFamily(familyId: familyId, name: name);

      if (res.isSuccess) {
        setState(() {
          final index = _families.indexWhere((f) => _familyId(f) == familyId);
          if (index >= 0) {
            _families[index] = {..._families[index], 'name': name};
          }
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已更新为「$name」'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: ${res.message}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      _log('ERROR: 更新家庭异常 - $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失败: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '处理中...';
        });
      }
    }
  }

  Future<void> _handleSwitchFamily(String familyId, String familyName) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = '切换中...';
    });

    try {
      final service = FamilyService();
      final res = await service.switchFamily(familyId: familyId);

      if (res.isSuccess) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已切换到「$familyName」'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('切换失败: ${res.message}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('切换失败: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '处理中...';
        });
      }
    }
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> family) {
    final familyId = _familyId(family);
    final familyName = family['name']?.toString() ?? '未命名';
    final role = _familyRole(family);
    final isCurrentFamily = familyId == widget.currentFamilyId;

    if (!_canDeleteFamily(role)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('只有创建者可以删除家庭')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildDeleteConfirmDialog(
        familyId,
        familyName,
        isCurrentFamily: isCurrentFamily,
        isLastFamily: _families.length <= 1,
      ),
    );
  }

  Widget _buildDeleteConfirmDialog(
    String familyId,
    String familyName, {
    bool isCurrentFamily = false,
    bool isLastFamily = false,
  }) {
    final TextEditingController controller = TextEditingController();
    bool canConfirm = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Row(
            children: [
              const CandyIcon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('删除家庭'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('确定要删除「$familyName」吗？'),
              const SizedBox(height: 8),
              const Text(
                '删除后该家庭下的所有物品数据将永久丢失，且无法恢复。',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              if (isLastFamily)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '这是您唯一的家庭，删除后将没有任何家庭，请尽快创建或加入新家庭。',
                    style: TextStyle(fontSize: 13, color: Colors.orange),
                  ),
                )
              else if (isCurrentFamily)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '这是当前正在使用的家庭，删除后将自动切换到您的其他家庭。',
                    style: TextStyle(fontSize: 13, color: Colors.orange),
                  ),
                ),
              const SizedBox(height: 16),
              const Text('请输入家庭名称以确认：'),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: '请输入「$familyName」',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    canConfirm = value.trim() == familyName;
                  });
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
              onPressed: canConfirm
                  ? () => _handleDeleteFamily(
                        context,
                        familyId,
                        familyName,
                        controller.text.trim(),
                        isCurrentFamily: isCurrentFamily,
                        isLastFamily: isLastFamily,
                      )
                  : null,
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(
                  canConfirm ? AppColors.danger : Colors.grey,
                ),
              ),
              child: const Text('确认删除'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteFamily(
    BuildContext dialogContext,
    String familyId,
    String familyName,
    String confirmName, {
    bool isCurrentFamily = false,
    bool isLastFamily = false,
  }) async {
    Navigator.pop(dialogContext);

    setState(() {
      _isLoading = true;
      _loadingMessage = '删除中...';
    });

    try {
      _log(
        'INFO: 删除家庭 - id=$familyId, isCurrent=$isCurrentFamily, '
        'isLastFamily=$isLastFamily',
      );
      final service = FamilyService();
      final res = await service.deleteFamily(
        familyId: familyId,
        confirmName: confirmName,
      );

      if (res.isSuccess) {
        setState(() {
          _families.removeWhere((f) => _familyId(f) == familyId);
        });
        if (!mounted) return;
        if (isCurrentFamily || isLastFamily || _families.isEmpty) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除「$familyName」'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: ${res.message}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      _log('ERROR: 删除家庭异常 - $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除失败: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '处理中...';
        });
      }
    }
  }

  Widget _buildFamilyCard(Map<String, dynamic> family) {
    final familyId = _familyId(family);
    final familyName = family['name']?.toString() ?? '未命名';
    final role = _familyRole(family);
    final memberCount = _memberCount(family);
    final itemCount = _itemCount(family);
    final isCurrentFamily = familyId == widget.currentFamilyId;
    final showMore = _canManageFamily(role);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentFamily ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentFamily ? null : Border.all(color: AppColors.gray200),
        boxShadow: isCurrentFamily
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isCurrentFamily) {
              _handleSwitchFamily(familyId, familyName);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isCurrentFamily)
                  Container(
                    width: 3,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrentFamily
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PresetIcon(
                    storageKey: family['icon']?.toString(),
                    name: familyName,
                    wellSize: 36,
                    iconSize: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              familyName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentFamily)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '✓ 当前',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$memberCount 人 · $itemCount 件 · ${_roleLabel(role)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showMore)
                  GestureDetector(
                    onTapDown: (details) => _showMoreMenu(family, details),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: CandyIcon(
                        CandyIcons.moreVert,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        AnimatedPositioned(
          bottom: 0,
          left: 0,
          right: 0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      const Text(
                        '选择家庭',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '当前共 ${_families.length} 个家庭',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const CandyIcon(CandyIcons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.gray200),
                if (_families.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('暂无家庭'),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: _families.map(_buildFamilyCard).toList(),
                      ),
                    ),
                  ),
                const Divider(height: 1, color: AppColors.gray200),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/create-family');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.gray300,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('＋ 创建新家庭'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/join-family');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.gray300,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('🔗 加入家庭'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_loadingMessage),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
