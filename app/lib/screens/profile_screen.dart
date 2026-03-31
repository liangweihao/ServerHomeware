import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/screens/login_screen.dart';

/// 个人中心屏幕类，用于显示用户信息和提供登出功能
class ProfileScreen extends StatefulWidget {
  /// 构造函数
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

/// ProfileScreen的状态类
class _ProfileScreenState extends State<ProfileScreen> {
  /// 初始化状态，加载用户资料
  @override
  void initState() {
    super.initState();
    // 使用addPostFrameCallback确保在构建完成后再加载数据，避免setState() during build错误
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.getUserProfile();
    });
  }

  /// 退出登录方法
  /// 调用authProvider执行登出操作，并导航回登录页面
  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  /// 构建UI界面
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 用户信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 头像
                      const CircleAvatar(
                        radius: 50,
                        child: Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: 16),
                      // 用户名
                      Text(
                        authProvider.user?.username ?? '未登录',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // 邮箱
                      Text(authProvider.user?.email ?? ''),
                      // 电话（如果有）
                      if (authProvider.user?.phone != null)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Text('电话: ${authProvider.user?.phone}'),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // 账号状态
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('账号状态: '),
                          Text(
                            authProvider.user?.isVerified == true ? '已验证' : '未验证',
                            style: TextStyle(
                              color: authProvider.user?.isVerified == true ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 功能列表
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('设置'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // 导航到设置页面
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('帮助与反馈'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // 导航到帮助页面
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('关于'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // 导航到关于页面
                },
              ),
              const SizedBox(height: 24),
              // 退出登录按钮
              ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('退出登录'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
