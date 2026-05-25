import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/items/item_list_page.dart';
import '../../presentation/items/item_detail_page.dart';
import '../../presentation/items/add_item_page.dart';
import '../../presentation/items/edit_item_page.dart';
import '../../presentation/items/scan_page.dart';
import '../../presentation/alerts/alert_center_page.dart';
import '../../presentation/profile/profile_page.dart';
import '../../presentation/profile/category_management_page.dart';
import '../../presentation/profile/family_management_page.dart';
import '../../presentation/profile/notification_settings_page.dart';
import '../../presentation/locations/location_overview_page.dart';
import '../../presentation/locations/location_detail_page.dart';
import '../../presentation/shopping/shopping_list_page.dart';
import '../../presentation/statistics/statistics_page.dart';
import '../../presentation/search/search_page.dart';
import '../../presentation/common/widgets/main_scaffold.dart';

/// 自定义过渡动画 - 渐隐渐显
class FadeTransitionPage<T> extends CustomTransitionPage<T> {
  FadeTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        );
}

/// 自定义过渡动画 - 从右侧滑入
class SlideTransitionPage<T> extends CustomTransitionPage<T> {
  SlideTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

// 路由配置
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 带底部导航的路由（ShellRoute）
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) => FadeTransitionPage(
            child: const HomePage(),
          ),
        ),
        GoRoute(
          path: '/items',
          name: 'items',
          pageBuilder: (context, state) => FadeTransitionPage(
            child: const ItemListPage(),
          ),
        ),
        GoRoute(
          path: '/alerts',
          name: 'alerts',
          pageBuilder: (context, state) => FadeTransitionPage(
            child: const AlertCenterPage(),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => FadeTransitionPage(
            child: const ProfilePage(),
          ),
        ),
      ],
    ),

    // 不带底部导航的全屏页面
    GoRoute(
      path: '/items/add',
      name: 'addItem',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const AddItemPage(),
      ),
    ),
    GoRoute(
      path: '/items/scan',
      name: 'scanItem',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const ScanPage(),
      ),
    ),
    GoRoute(
      path: '/items/:id',
      name: 'itemDetail',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: ItemDetailPage(id: int.parse(state.pathParameters['id']!)),
      ),
    ),
    GoRoute(
      path: '/items/:id/edit',
      name: 'editItem',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: EditItemPage(id: int.parse(state.pathParameters['id']!)),
      ),
    ),
    GoRoute(
      path: '/locations',
      name: 'locations',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const LocationOverviewPage(),
      ),
    ),
    GoRoute(
      path: '/locations/:id',
      name: 'locationDetail',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: LocationDetailPage(locationId: int.parse(state.pathParameters['id']!)),
      ),
    ),
    GoRoute(
      path: '/shopping',
      name: 'shopping',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const ShoppingListPage(),
      ),
    ),
    GoRoute(
      path: '/statistics',
      name: 'statistics',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const StatisticsPage(),
      ),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const SearchPage(),
      ),
    ),
    // Profile 子页面
    GoRoute(
      path: '/profile/categories',
      name: 'categoryManagement',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const CategoryManagementPage(),
      ),
    ),
    GoRoute(
      path: '/profile/family',
      name: 'familyManagement',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const FamilyManagementPage(),
      ),
    ),
    GoRoute(
      path: '/profile/notification-settings',
      name: 'notificationSettings',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const NotificationSettingsPage(),
      ),
    ),
  ],
);
