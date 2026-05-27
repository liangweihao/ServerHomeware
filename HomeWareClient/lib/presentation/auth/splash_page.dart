import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';

/// 启动页
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  static const _keyToken = 'auth_token';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// 检查认证状态并验证token
  Future<void> _checkAuth() async {
    // 等待 500ms 显示启动画面
    await Future.delayed(const Duration(milliseconds: 500));

    // 首先检查本地是否有token
    final hasToken = await _hasLocalToken();
    
    if (!mounted) return;

    if (!hasToken) {
      // 无token，跳转到欢迎页
      context.go('/welcome');
      return;
    }

    // 有token，验证token有效性
    final authService = AuthService();
    final tokenResult = await authService.validateToken();

    if (!mounted) return;

    if (tokenResult.code == 200) {
      // token有效，跳转到首页
      context.go('/');
    } else {
      // token无效或过期，清除本地token并跳转到登录页
      await _clearLocalToken();
      if (!mounted) return;
      context.go('/login');
    }
  }

  /// 检查本地是否有token
  Future<bool> _hasLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return token != null && token.isNotEmpty;
  }

  /// 清除本地token
  Future<void> _clearLocalToken() async {
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: const Text(
                '🏠📦',
                style: TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 16),
            // App 名称
            Text(
              'HomeStock',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 4),
            // 副标题
            Text(
              '家庭物品管家',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.gray500,
                  ),
            ),
            const SizedBox(height: 48),
            // 加载动画
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
