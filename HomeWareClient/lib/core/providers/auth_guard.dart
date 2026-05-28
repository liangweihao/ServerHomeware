import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import '../exceptions/auth_exception.dart';
import '../services/api_service.dart';

/// 全局认证守卫 Widget
/// 监听认证状态变化，当 token 无效时自动跳转到登录页面
class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 设置全局认证错误回调
    ApiService.setAuthErrorCallback(() {
      _handleGlobalAuthError(context, ref);
    });

    // 监听认证状态
    ref.listen<AsyncValue<AuthState>>(
      authProvider,
      (previous, next) {
        if (next.hasError) {
          final error = next.error;
          if (error is AuthException) {
            // 认证异常，跳转到登录页面
            _handleAuthError(context, error);
          }
        }
        
        // 监听状态变化
        next.whenData((state) {
          if (state == AuthState.unauthenticated) {
            // 用户未登录，跳转到登录页面
            _navigateToLogin(context);
          }
        });
      },
    );

    return child;
  }

  /// 处理全局认证错误（来自API响应）
  void _handleGlobalAuthError(BuildContext context, WidgetRef ref) {
    // 清除认证状态
    ref.read(authProvider.notifier).logout();
    
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('登录已过期，请重新登录'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
    
    // 跳转到登录页面
    _navigateToLogin(context);
  }

  /// 处理认证错误
  void _handleAuthError(BuildContext context, AuthException error) {
    switch (error.type) {
      case AuthExceptionType.tokenExpired:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('登录已过期，请重新登录'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case AuthExceptionType.tokenInvalid:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('登录无效，请重新登录'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        break;
      case AuthExceptionType.unauthorized:
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text('暂无权限，请重新登录'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        break;
    }
    _navigateToLogin(context);
  }

  /// 导航到登录页面
  void _navigateToLogin(BuildContext context) {
    // 避免重复导航
    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath != '/login' && 
        currentPath != '/welcome' && 
        currentPath != '/splash') {
      context.go('/login');
    }
  }
}

/// 全局错误处理扩展
extension AuthErrorHandling on WidgetRef {
  /// 处理 API 响应中的认证错误
  void handleApiAuthError(int code, String message) {
    if (shouldTriggerSessionLogout(code, message)) {
      // 获取 AuthNotifier 并调用退出登录
      read(authProvider.notifier).logout();
      
      // 抛出认证异常
      throw AuthException(
        message: message,
        type: getAuthExceptionType(code),
      );
    }
  }
}