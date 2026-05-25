import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';

/// 启动页
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  /// 检查认证状态
  Future<void> _checkAuth() async {
    // 等待 1.5 秒
    await Future.delayed(const Duration(milliseconds: 1500));

    // 获取当前认证状态
    final authState = await ref.read(authProvider.future);

    if (!mounted) return;

    // 根据状态跳转
    switch (authState) {
      case AuthState.firstLaunch:
        context.go('/welcome');
        break;
      case AuthState.authenticated:
        context.go('/');
        break;
      case AuthState.unauthenticated:
      case AuthState.needCompleteProfile:
        context.go('/login');
        break;
    }
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
