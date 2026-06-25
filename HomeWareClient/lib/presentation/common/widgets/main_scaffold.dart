import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/alert_provider.dart';
import 'cartoon_bottom_nav.dart';

/// 主 Tab 脚手架 — 卡通浮动底栏
class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  /// 根据路由路径解析当前 Tab 索引
  static int indexFromPath(String path) {
    if (path.startsWith('/items')) return 1;
    if (path.startsWith('/alerts')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/items');
        break;
      case 2:
        context.go('/alerts');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  bool _isMainRoute() {
    return !Navigator.of(context).canPop();
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final currentIndex = indexFromPath(path);

    final body = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: MediaQuery.paddingOf(context).copyWith(
          bottom: CartoonBottomNav.totalHeight(context),
        ),
      ),
      child: widget.child,
    );

    return WillPopScope(
      onWillPop: () async {
        if (_isMainRoute()) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.scaffoldBackground,
        body: body,
        bottomNavigationBar: Builder(
          builder: (context) {
            final alertCountAsync = ref.watch(unreadAlertCountProvider);
            final alertCount = alertCountAsync.value ?? 0;

            return ColoredBox(
              color: Colors.transparent,
              child: CartoonBottomNav(
                currentIndex: currentIndex,
                onTap: _onItemTapped,
                alertCount: alertCount,
              ),
            );
          },
        ),
      ),
    );
  }
}
