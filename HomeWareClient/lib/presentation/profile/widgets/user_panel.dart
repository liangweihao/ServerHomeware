import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/family_service.dart';
import '../../../core/services/contribution_service.dart';

/// 用户个人面板（从右侧滑出）
class UserPanel extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const UserPanel({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<UserPanel> createState() => _UserPanelState();
}

class _UserPanelState extends ConsumerState<UserPanel> {
  bool _isLoading = true;
  Map<String, dynamic>? _familyData;
  Map<String, dynamic>? _contributionData;
  String _inviteCode = '';
  List<Map<String, dynamic>> _families = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // 并行获取数据
      final familyService = FamilyService();
      final contributionService = ContributionService();
      final userId = ''; // 实际应该从AuthProvider获取
      
      final results = await Future.wait([
        familyService.getCurrentFamily(userId: userId),
        contributionService.getUserContribution(userId: userId),
        familyService.getUserFamilies(),
      ]);
      
      final familyRes = results[0] as ApiResponse<Map<String, dynamic>>;
      final contributionRes = results[1] as ApiResponse<Map<String, dynamic>>;
      final familiesRes = results[2] as ApiResponse<List<dynamic>>;
      
      if (familyRes.isSuccess) {
        setState(() {
          _familyData = familyRes.data;
          _inviteCode = _familyData?['invite_code'] ?? '';
        });
      }
      
      if (familiesRes.isSuccess) {
        setState(() {
          _families = familiesRes.data?.cast<Map<String, dynamic>>() ?? [];
        });
      }
      
      if (contributionRes.isSuccess) {
        setState(() {
          _contributionData = contributionRes.data;
        });
      }
    } catch (e) {
      // 忽略错误，显示默认数据
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 复制邀请码
  Future<void> _copyInviteCode() async {
    // 实际项目中使用 Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('邀请码已复制')),
    );
  }

  /// 刷新邀请码
  void _refreshInviteCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刷新邀请码'),
        content: const Text('刷新后旧邀请码将失效，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final service = FamilyService();
              final res = await service.refreshInviteCode(familyId: '');
              if (res.isSuccess) {
                setState(() {
                  _inviteCode = res.data?['invite_code'] ?? '';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('邀请码已刷新')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 退出登录确认
  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出？'),
        content: const Text('退出后需要重新登录才能使用'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              widget.onClose();
              context.go('/login');
            },
            child: const Text('确认退出', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authProvider.notifier).currentUser;
    
    // 获取头像信息
    final avatarIndex = AuthService.getAvatarColorIndex(user?.phone ?? '');
    final colors = AuthService.getAvatarColors(avatarIndex);
    String displayChar = '?';
    if (user?.nickname != null && user!.nickname!.isNotEmpty) {
      displayChar = user.nickname![0].toUpperCase();
    } else if (user?.phone != null) {
      displayChar = user!.phone!.substring(7, 11);
    }

    final panelWidth = min(MediaQuery.of(context).size.width * 0.8, 320.0);
  
    return Container(
      width: panelWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像区域（带渐变背景）
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 大头像
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(colors[0]), Color(colors[1])],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        displayChar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 昵称和手机号
                  Text(
                    user?.nickname ?? '用户',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _maskPhone(user?.phone ?? ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 编辑资料按钮
                  TextButton(
                    onPressed: () {
                      widget.onClose();
                      context.push('/profile/edit');
                    },
                    child: Text(
                      '编辑资料',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 分割线
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: AppColors.gray200,
          ),

          // 滚动内容区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 当前家庭区域
                  _buildFamilySection(),

                  // 分割线
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    color: AppColors.gray200,
                  ),

                  // 我的贡献区域
                  _buildContributionSection(),

                  // 分割线
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    color: AppColors.gray200,
                  ),

                  // 功能入口列表
                  _buildFunctionList(),

                  // 分割线
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    color: AppColors.gray200,
                  ),

                  // 退出登录
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: TextButton(
                      onPressed: _showLogoutConfirm,
                      child: Text(
                        '🚪 退出登录',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 家庭信息区域
  Widget _buildFamilySection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final members = _familyData?['members'] as List? ?? [];
    final memberCount = members.length;
    final itemCount = _familyData?['item_count'] ?? 0;
    final familyName = _familyData?['name'] ?? '我的家庭';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区块标题
          const Row(
            children: [
              Text('🏠'),
              SizedBox(width: 4),
              Text('当前家庭'),
            ],
          ),
          const SizedBox(height: 12),

          // 家庭卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              children: [
                // 家庭名
                Text(
                  familyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // 成员头像列表
                Row(
                  children: List.generate(
                    min(members.length, 5),
                    (index) => _buildMemberAvatar(members[index]),
                  )..addAll([
                      if (members.length > 5)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gray100,
                          ),
                          child: Center(
                            child: Text(
                              '+${members.length - 5}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.gray500,
                              ),
                            ),
                          ),
                        ),
                    ]),
                ),
                const SizedBox(height: 8),

                // 统计摘要
                Text(
                  '$memberCount位成员 · $itemCount件物品',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 12),

                // 邀请码
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '邀请码：',
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                    Text(
                      _inviteCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 复制和刷新按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _copyInviteCode,
                      child: const Text('📋 复制'),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: _refreshInviteCode,
                      child: const Text('🔄 刷新'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 管理成员和切换家庭按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onClose();
                    context.push('/profile/family');
                  },
                  child: const Text('👥 管理成员'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _showSwitchFamilyDialog,
                  child: const Text('🏠 切换家庭'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 成员头像
  Widget _buildMemberAvatar(Map member) {
    final name = member['name'] as String? ?? '?';
    final colorIndex = name.hashCode.abs() % AuthService.avatarColors.length;
    final colors = AuthService.getAvatarColors(colorIndex);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(colors[0]), Color(colors[1])],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 切换家庭弹窗
  void _showSwitchFamilyDialog() {
    final currentFamilyId = (_familyData?['id'] as dynamic)?.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('选择家庭'),
            Spacer(),
            Icon(Icons.close),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 家庭列表
            if (_families.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('暂无家庭'),
              )
            else
              ..._families.map((family) {
                final familyId = (family['id'] as dynamic)?.toString();
                final isCurrent = familyId == currentFamilyId;
                final memberCount = family['member_count'] ?? 0;
                final itemCount = family['item_count'] ?? 0;
                
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (isCurrent) {
                          // 已是当前家庭，关闭弹窗
                          Navigator.pop(context);
                          return;
                        }
                        
                        // 调用API切换家庭
                        final service = FamilyService();
                        final res = await service.switchFamily(familyId: familyId ?? '');
                        
                        if (res.isSuccess) {
                          // 切换成功，更新本地状态
                          setState(() {
                            _familyData = res.data;
                            _inviteCode = res.data?['invite_code'] ?? '';
                          });
                          
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已切换到「${family['name']}」')),
                          );
                        } else {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('切换失败: ${res.message}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrent ? AppColors.primary.withValues(alpha: 0.1) : AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: isCurrent ? null : Border.all(color: AppColors.gray200),
                        ),
                        child: Row(
                          children: [
                            isCurrent ? const Icon(Icons.check, color: AppColors.primary) : const SizedBox(width: 24),
                            const SizedBox(width: 8),
                            Expanded(child: Text(family['name'] ?? '未命名')),
                            Text(
                              '$memberCount人 · $itemCount件',
                              style: TextStyle(color: AppColors.gray500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }),
            
            // 分隔线
            if (_families.isNotEmpty) ...[
              Container(height: 1, color: AppColors.gray200),
              const SizedBox(height: 16),
            ],

            // 创建和加入按钮
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('+ 创建新家庭'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('🔗 加入其他家庭'),
            ),
          ],
        ),
      ),
    );
  }

  /// 贡献度区域
  Widget _buildContributionSection() {
    if (_isLoading) {
      return const SizedBox(height: 80);
    }

    final inputCount = _contributionData?['monthly_input'] ?? 0;
    final consumptionCount = _contributionData?['monthly_consumption'] ?? 0;
    final contributionRate = (_contributionData?['contribution_rate'] ?? 0.0) * 100;
    final encouragement = _contributionData?['encouragement'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 区块标题
          const Row(
            children: [
              Text('📊'),
              SizedBox(width: 4),
              Text('我的贡献（本月）'),
            ],
          ),
          const SizedBox(height: 12),

          // 贡献数据卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              children: [
                // 录入和消耗记录
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$inputCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '录入',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$consumptionCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '消耗记录',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 贡献度进度条
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('家庭贡献度'),
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: contributionRate,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('${contributionRate.toStringAsFixed(0)}%'),
                ),
                if (encouragement.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    encouragement,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 功能入口列表
  Widget _buildFunctionList() {
    final functions = [
      {'icon': '⚙️', 'title': '设置', 'route': '/profile/notification-settings'},
      {'icon': '📋', 'title': '盘点任务', 'route': null},
      {'icon': '📤', 'title': '数据导出', 'route': null},
      {'icon': '❓', 'title': '帮助与反馈', 'route': null},
      {'icon': '📱', 'title': '关于 HomeStock', 'route': null},
    ];

    return Column(
      children: functions
          .map((item) => InkWell(
                onTap: () {
                  if (item['route'] != null) {
                    widget.onClose();
                    context.push(item['route']!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('功能开发中')),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Text(item['icon']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item['title']!)),
                      const Icon(Icons.chevron_right, color: AppColors.gray400),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  /// 手机号脱敏
  String _maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
}

/// 个人面板遮罩层
class UserPanelOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const UserPanelOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<UserPanelOverlay> createState() => _UserPanelOverlayState();
}

class _UserPanelOverlayState extends ConsumerState<UserPanelOverlay> {
  bool _isPanelOpen = false;

  void _openPanel() {
    setState(() => _isPanelOpen = true);
  }

  void _closePanel() {
    setState(() => _isPanelOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // 头像按钮（用于打开面板）
        Positioned(
          top: 60,
          right: 16,
          child: GestureDetector(
            onTap: _openPanel,
            child: _buildAvatarButton(),
          ),
        ),

        // 面板遮罩和面板
        if (_isPanelOpen) ...[
          // 遮罩
          GestureDetector(
            onTap: _closePanel,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // 面板（从右侧滑入）
          AnimatedPositioned(
            right: _isPanelOpen ? 0 : MediaQuery.of(context).size.width * 0.8,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.8,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: UserPanel(onClose: _closePanel),
          ),
        ],
      ],
    );
  }

  /// 头像按钮
  Widget _buildAvatarButton() {
    final user = ref.read(authProvider.notifier).currentUser;
    final avatarIndex = AuthService.getAvatarColorIndex(user?.phone ?? '');
    final colors = AuthService.getAvatarColors(avatarIndex);
    String displayChar = '?';
    if (user?.nickname != null && user!.nickname!.isNotEmpty) {
      displayChar = user.nickname![0].toUpperCase();
    } else if (user?.phone != null) {
      displayChar = user!.phone!.substring(7, 11);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(colors[0]), Color(colors[1])],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
    );
  }
}
