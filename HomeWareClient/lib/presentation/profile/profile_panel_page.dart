import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/family_service.dart';
import '../../core/services/contribution_service.dart';

class ProfilePanelPage extends ConsumerStatefulWidget {
  const ProfilePanelPage({super.key});

  @override
  ConsumerState<ProfilePanelPage> createState() => _ProfilePanelPageState();
}

class _ProfilePanelPageState extends ConsumerState<ProfilePanelPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _familyData;
  Map<String, dynamic>? _contributionData;
  String _inviteCode = '';
  bool _familyNetworkError = false;
  bool _contributionNetworkError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _familyNetworkError = false;
      _contributionNetworkError = false;
    });

    try {
      final user = ref.read(authProvider.notifier).currentUser;
      final userId = user?.id ?? '1';
      
      final familyService = FamilyService();
      final contributionService = ContributionService();

      final familyResult = await familyService.getCurrentFamily(userId: userId);
      if (familyResult.code == 200) {
        setState(() {
          _familyData = familyResult.data;
          _inviteCode = familyResult.data?['invite_code'] ?? '';
        });
      } else {
        setState(() {
          _familyData = null;
        });
      }

      final contributionResult = await contributionService.getUserContribution(userId: userId);
      if (contributionResult.code == 200) {
        setState(() {
          _contributionData = contributionResult.data;
        });
      } else {
        setState(() {
          _contributionData = null;
        });
      }
    } catch (e) {
      debugPrint('Failed to load data: $e');
      setState(() {
        _familyNetworkError = true;
        _contributionNetworkError = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出？'),
        content: const Text('退出后需要重新登录才能使用\n本地未同步的数据不会丢失'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('确认退出', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  Future<void> _copyInviteCode() async {
    if (_inviteCode.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('邀请码已复制')),
      );
    }
  }

  Future<void> _refreshInviteCode() async {
    try {
      final familyService = FamilyService();
      final familyId = _familyData?['id'] ?? '1';
      final result = await familyService.refreshInviteCode(familyId: familyId);
      if (result.code == 200) {
        setState(() {
          _inviteCode = result.data?['invite_code'] ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('邀请码已刷新')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('刷新失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 40;
    final user = ref.read(authProvider.notifier).currentUser;
    final avatarIndex = AuthService.getAvatarColorIndex(user?.phone ?? '');
    final colors = AuthService.getAvatarColors(avatarIndex);
    String displayChar = '?';
    if (user?.nickname != null && user!.nickname!.isNotEmpty) {
      displayChar = user.nickname![0].toUpperCase();
    } else if (user?.phone != null) {
      displayChar = user!.phone!.substring(user.phone!.length - 4);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('个人中心'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildHeaderSection(colors, displayChar, user),
              const SizedBox(height: 20),
              _buildFamilySection(cardWidth),
              const SizedBox(height: 16),
              _buildContributionSection(cardWidth),
              const SizedBox(height: 16),
              _buildFunctionList(cardWidth),
              const SizedBox(height: 20),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(List<int> colors, String displayChar, dynamic user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.08),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(colors[0]), Color(colors[1])],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                displayChar,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.nickname ?? '用户',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _maskPhone(user?.phone ?? ''),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.push('/profile/edit'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(120, 36),
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '编辑资料',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilySection(double width) {
    if (_isLoading) {
      return SizedBox(
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (_familyNetworkError) {
      return SizedBox(
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  '🏠 当前家庭',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '❌ 网络连接失败',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '请检查网络后重试',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 40),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_familyData == null) {
      return SizedBox(
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  '🏠 当前家庭',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🏠 您还没有加入任何家庭',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '邀请家人一起管理物品吧！',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.push('/create-family'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 40),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('创建家庭'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.push('/join-family'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 40),
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.grey[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('加入家庭'),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
      );
    }

    final familyName = _familyData?['name'] ?? '未加入家庭';
    final members = _familyData?['members'] ?? [];

    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.gray200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏠 当前家庭',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                familyName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(
                  min(members.length, 5),
                  (index) => _buildMemberAvatar(members[index]),
                )..addAll([
                    if (members.length > 5)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gray100,
                        ),
                        child: Center(
                          child: Text(
                            '+${members.length - 5}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
                      ),
                  ]),
              ),
              const SizedBox(height: 12),
              Text(
                '${members.length}位成员 · ${_familyData?['item_count'] ?? 0}件物品',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    '邀请码：',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _inviteCode.isNotEmpty ? _inviteCode : '暂无',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _copyInviteCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(90, 36),
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('📋 复制'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _refreshInviteCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(90, 36),
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('🔄 刷新'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.push('/profile/family'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('👥 管理成员'),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => _showSwitchFamily(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('🏠 切换家庭'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberAvatar(dynamic member) {
    final name = member['nickname'] ?? member['phone'] ?? '?';
    final displayChar = name is String && name.isNotEmpty 
        ? name[0].toUpperCase() 
        : '?';
    final index = name.hashCode.abs() % 10;
    final colors = AuthService.getAvatarColors(index);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContributionSection(double width) {
    if (_isLoading) {
      return SizedBox(
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    if (_contributionNetworkError) {
      return SizedBox(
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  '📊 我的贡献（本月）',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '❌ 获取数据失败',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  '请检查网络后重试',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 40),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_contributionData == null) {
      return SizedBox(
        width: width,
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.gray200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  '📊 我的贡献（本月）',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '📊 暂无贡献数据',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  '加入家庭后即可记录贡献',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final recordCount = _contributionData?['record_count'] ?? 0;
    final consumeCount = _contributionData?['consume_count'] ?? 0;
    final contribution = _contributionData?['contribution'] ?? 0;

    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.gray200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 我的贡献（本月）',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('录入', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                          const SizedBox(height: 4),
                          Text('$recordCount 件', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text('消耗记录', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                          const SizedBox(height: 4),
                          Text('$consumeCount 次', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('家庭贡献度'),
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
                    width: width * 0.92 * (contribution / 100),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.success],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('你的操作占全家的比例'),
                  Text(
                    '$contribution%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '本月你比上月多录入了5件 👍',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionList(double width) {
    final functions = [
      {'icon': '⚙️', 'title': '设置', 'route': '/profile/notification-settings'},
      {'icon': '📋', 'title': '盘点任务', 'route': null},
      {'icon': '📤', 'title': '数据导出', 'route': null},
      {'icon': '❓', 'title': '帮助与反馈', 'route': null},
      {'icon': '📱', 'title': '关于 HomeStock', 'route': null},
    ];

    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.gray200),
        ),
        child: Column(
          children: functions
              .map((func) => InkWell(
                    onTap: () {
                      if (func['route'] != null) {
                        context.push(func['route']!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${func['title']}功能开发中')),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(
                        children: [
                          Text(func['icon']!, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              func['title']!,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: _showLogoutConfirm,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.danger,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '🚪 退出登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showSwitchFamily() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '选择家庭',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('温馨小窝'),
              subtitle: const Text('3人 · 95件'),
              leading: const Icon(Icons.check, color: AppColors.success),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('老家'),
              subtitle: const Text('2人 · 43件'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已切换到「老家」')),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            TextButton(
              onPressed: () => context.push('/create-family'),
              child: const Text('+ 创建新家庭'),
            ),
            TextButton(
              onPressed: () => context.push('/join-family'),
              child: const Text('🔗 加入其他家庭'),
            ),
          ],
        ),
      ),
    );
  }

  String _maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
}