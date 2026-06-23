import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/error_handler.dart';

/// 编辑资料页
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nicknameController = TextEditingController();
  final _familyNicknameController = TextEditingController();
  bool _isLoading = false;
  String? _nicknameError;
  String? _familyNicknameError;
  String _email = ''; // 邮箱字段
  
  // 当前头像颜色索引
  int _avatarColorIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }
  
  void _loadCurrentUser() {
    final user = ref.read(authProvider.notifier).currentUser;
    if (user != null) {
      _nicknameController.text = user.nickname ?? '';
      _familyNicknameController.text = user.nickname ?? '';
      
      // 获取头像颜色索引
      if (user.avatar != null && user.avatar!.startsWith('avatar_')) {
        _avatarColorIndex = int.tryParse(user.avatar!.replaceFirst('avatar_', '')) ?? 0;
      } else {
        _avatarColorIndex = AuthService.getAvatarColorIndex(user.phone);
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _familyNicknameController.dispose();
    super.dispose();
  }
  
  /// 验证输入
  bool _validate() {
    bool isValid = true;
    setState(() {
      _nicknameError = null;
      _familyNicknameError = null;
    });

    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      setState(() {
        _nicknameError = '请输入昵称';
      });
      isValid = false;
    } else if (nickname.length > 50) {
      setState(() {
        _nicknameError = '昵称不能超过50个字符';
      });
      isValid = false;
    }

    return isValid;
  }
  
  /// 保存资料
  Future<void> _saveProfile() async {
    if (!_validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authProvider.notifier).updateProfile(
        nickname: _nicknameController.text.trim(),
        avatar: 'avatar_$_avatarColorIndex',
        familyNickname: _familyNicknameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[EditProfilePage] 保存资料',
        userMessage: '保存失败，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// 显示头像选择器
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _AvatarPickerSheet(
        currentIndex: _avatarColorIndex,
        onSelect: (index) {
          setState(() {
            _avatarColorIndex = index;
          });
          Navigator.pop(context);
        },
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
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              '确认退出',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider.notifier).currentUser;
    
    // 获取头像颜色
    final colors = AuthService.getAvatarColors(_avatarColorIndex);
    
    // 获取显示字符
    String displayChar = '?';
    if (_nicknameController.text.isNotEmpty) {
      displayChar = _nicknameController.text[0].toUpperCase();
    } else if (user?.phone != null) {
      displayChar = user!.phone!.substring(7, 11);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: const Text('编辑资料'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            // 头像区域
            GestureDetector(
              onTap: _showAvatarPicker,
              child: Hero(
                tag: 'user_avatar',
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(colors[0]),
                            Color(colors[1]),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          displayChar,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            Text(
              '点击更换头像',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 表单区域
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 昵称
                  _buildLabel('昵称'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nicknameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: '请输入昵称',
                      errorText: _nicknameError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.gray300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (_) {
                      if (_nicknameError != null) {
                        setState(() {
                          _nicknameError = null;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 手机号
                  _buildLabel('手机号'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _maskPhone(user?.phone ?? ''),
                            style: TextStyle(
                              color: AppColors.gray700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: 更换手机号
                          },
                          child: const Text('更换'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 邮箱（可选）
                  _buildLabel('邮箱（可选）'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _email.isEmpty ? '未绑定' : _email,
                            style: TextStyle(
                              color: AppColors.gray700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: 绑定邮箱
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('功能开发中')),
                            );
                          },
                          child: const Text('绑定'),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 家庭内称呼
                  _buildLabel('家庭内称呼'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _familyNicknameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: '在家庭中显示的名字',
                      errorText: _familyNicknameError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.gray300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (_) {
                      if (_familyNicknameError != null) {
                        setState(() {
                          _familyNicknameError = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 修改密码
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: 修改密码
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('功能开发中')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Text('修改密码'),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.gray400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 注销账号
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: InkWell(
                onTap: () {
                  // TODO: 注销账号
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('功能开发中')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Text(
                        '注销账号',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 退出登录
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: InkWell(
                onTap: _showLogoutConfirm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      const Text(
                        '退出登录',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  /// 构建标签
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
    );
  }
  
  /// 手机号脱敏
  String _maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
}

/// 头像选择器底部弹窗
class _AvatarPickerSheet extends StatelessWidget {
  final int currentIndex;
  final Function(int) onSelect;
  
  const _AvatarPickerSheet({
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择头像颜色',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // 头像颜色网格
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: AuthService.avatarColors.length,
            itemBuilder: (context, index) {
              final colors = AuthService.getAvatarColors(index);
              final isSelected = index == currentIndex;
              
              return GestureDetector(
                onTap: () => onSelect(index),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(colors[0]),
                        Color(colors[1]),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
