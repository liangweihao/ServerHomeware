import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
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
  List<Map<String, dynamic>> _families = [];
  String? _menuFamilyId;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _families = List.from(widget.families);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _closeMenu() {
    _removeOverlay();
    setState(() {
      _menuFamilyId = null;
    });
  }

  void _showMoreMenu(Map<String, dynamic> family) {
    final fid = (family['id'] as dynamic)?.toString() ?? '';
    if (_menuFamilyId == fid) {
      _closeMenu();
      return;
    }

    // 移除旧的 overlay
    _removeOverlay();

    // 创建新的 overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 点击遮罩关闭菜单
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 菜单
          Positioned(
            right: 24,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 160,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 编辑家庭（置灰，暂不实现）
                    InkWell(
                      onTap: _closeMenu,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              '编辑家庭',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 删除家庭
                    InkWell(
                      onTap: () {
                        _closeMenu();
                        _showDeleteConfirmDialog(family);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '删除家庭',
                              style: TextStyle(
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _menuFamilyId = fid;
    });
  }

  Future<void> _handleSwitchFamily(String familyId, String familyName) async {
    setState(() => _isLoading = true);

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
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> family) {
    final familyId = (family['id'] as dynamic)?.toString() ?? '';
    final familyName = family['name'] ?? '未命名';
    final role = family['role'] ?? 'member';
    final isCurrentFamily = familyId == widget.currentFamilyId;
    final isCreator = role == 'owner';

    if (!isCreator) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('只有创建者可以删除家庭')),
      );
      return;
    }

    if (_families.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('至少需要保留一个家庭')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildDeleteConfirmDialog(familyId, familyName, isCurrentFamily),
    );
  }

  Widget _buildDeleteConfirmDialog(String familyId, String familyName, [bool isCurrentFamily = false]) {
    final TextEditingController controller = TextEditingController();
    bool canConfirm = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
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
              if (isCurrentFamily)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    '当前家庭将被删除，系统将自动切换到其他家庭。',
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
                  ? () => _handleDeleteFamily(context, familyId, familyName, controller.text.trim())
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
    String confirmName,
  ) async {
    Navigator.pop(dialogContext);

    setState(() => _isLoading = true);

    try {
      final service = FamilyService();
      final res = await service.deleteFamily(familyId: familyId, confirmName: confirmName);

      if (res.isSuccess) {
        setState(() {
          _families.removeWhere((f) => (f['id'] as dynamic)?.toString() == familyId);
        });
        if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除失败: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFamilyCard(Map<String, dynamic> family) {
    final familyId = (family['id'] as dynamic)?.toString() ?? '';
    final familyName = family['name'] ?? '未命名';
    final ownerId = family['owner_id'];
    
    // 对于当前家庭，用 currentFamilyData 的完整信息
    int memberCount = 0;
    int itemCount = 0;
    bool isCreator = false;
    
    if (familyId == widget.currentFamilyId && widget.currentFamilyData != null) {
      // 当前家庭用完整数据
      memberCount = widget.currentFamilyData!['member_count'] ?? 0;
      itemCount = widget.currentFamilyData!['item_count'] ?? 0;
      final members = widget.currentFamilyData!['members'] ?? [];
      final userIdStr = (widget.userId as dynamic)?.toString();
      // 在 members 数组中找当前用户的 role
      for (var member in members) {
        if (member['user_id']?.toString() == userIdStr) {
          isCreator = member['role'] == 'owner';
          break;
        }
      }
    } else {
      // 其他家庭用 owner_id 判断
      final userIdStr = (widget.userId as dynamic)?.toString();
      final ownerIdStr = (ownerId as dynamic)?.toString();
      isCreator = userIdStr != null && ownerIdStr != null && userIdStr == ownerIdStr;
      // 暂时用 0，后端接口需要更新
      memberCount = 0;
      itemCount = 0;
    }
    
    final isCurrentFamily = familyId == widget.currentFamilyId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentFamily ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentFamily
            ? null
            : Border.all(color: AppColors.gray200),
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
            if (_menuFamilyId != null) {
              _closeMenu();
            } else if (!isCurrentFamily) {
              _handleSwitchFamily(familyId, familyName);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 左侧竖线（当前家庭）
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
                // 家庭图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrentFamily
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                // 家庭信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            familyName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
                        '👥 $memberCount人 · 📦 $itemCount件 · ${isCreator ? '创建者' : '成员'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 更多按钮
                if (isCreator)
                  GestureDetector(
                    onTap: () => _showMoreMenu(family),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: AppColors.gray400,
                      ),
                    ),
                  ),
                if (!isCreator) const SizedBox(width: 40),
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
        // 遮罩
        GestureDetector(
          onTap: () {
            _closeMenu();
            Navigator.pop(context);
          },
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
        // 弹窗内容
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
                // 拖拽指示条
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
                // 标题区域
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
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _closeMenu();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // 分割线
                const Divider(height: 1, color: AppColors.gray200),
                // 家庭列表
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
                        children: _families
                            .map((family) => _buildFamilyCard(family))
                            .toList(),
                      ),
                    ),
                  ),
                // 分割线
                const Divider(height: 1, color: AppColors.gray200),
                // 创建/加入按钮
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _closeMenu();
                            Navigator.pop(context);
                            context.push('/create-family');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
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
                            _closeMenu();
                            Navigator.pop(context);
                            context.push('/join-family');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
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
                // 底部安全区域
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
        // Loading 蒙层
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('切换中...'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
