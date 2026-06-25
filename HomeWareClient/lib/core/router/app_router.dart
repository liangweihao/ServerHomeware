import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/home/home_page.dart';
import '../../presentation/items/item_list_page.dart';
import '../../presentation/items/item_detail_page.dart';
import '../../presentation/items/add_item_page.dart';
import '../../presentation/items/edit_item_page.dart';
import '../../presentation/items/usage_records_page.dart';
import '../../presentation/items/scan_page.dart';
import '../../presentation/alerts/alert_center_page.dart';
import '../../presentation/profile/profile_page.dart';
import '../../presentation/profile/profile_panel_page.dart';
import '../../presentation/profile/edit_profile_page.dart';
import '../../presentation/profile/category_management_page.dart';
import '../../presentation/profile/family_management_page.dart';
import '../../presentation/profile/notification_settings_page.dart';
import '../../presentation/locations/location_overview_page.dart';
import '../../presentation/locations/location_detail_page.dart';
import '../../presentation/shopping/shopping_list_page.dart';
import '../../presentation/statistics/statistics_page.dart';
import '../../presentation/notifications/notification_center_page.dart';
import '../../presentation/search/search_page.dart';
import '../../presentation/common/widgets/main_scaffold.dart';
import '../../presentation/auth/splash_page.dart';
import '../../presentation/auth/welcome_page.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/auth/register_page.dart';
import '../../presentation/auth/verify_code_page.dart';
import '../../presentation/auth/forgot_password_page.dart';
import '../../presentation/auth/create_family_page.dart';
import '../../presentation/auth/join_family_page.dart';

/// 全局 RouteObserver，用于监听页面可见性变化
final routeObserver = RouteObserver<ModalRoute>();

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
  observers: [routeObserver],
  initialLocation: '/splash',
  routes: [
    // 认证相关路由
    GoRoute(
      path: '/splash',
      name: 'splash',
      pageBuilder: (context, state) => FadeTransitionPage(
        child: const SplashPage(),
      ),
    ),
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      pageBuilder: (context, state) => FadeTransitionPage(
        child: const WelcomePage(),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/verify-code',
      name: 'verifyCode',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const VerifyCodePage(),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const ForgotPasswordPage(),
      ),
    ),
    GoRoute(
      path: '/create-family',
      name: 'createFamily',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const CreateFamilyPage(),
      ),
    ),
    GoRoute(
      path: '/join-family',
      name: 'joinFamily',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const JoinFamilyPage(),
      ),
    ),

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
      path: '/items/:id/edit',
      name: 'editItem',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: EditItemPage(id: int.parse(state.pathParameters['id']!)),
      ),
    ),
    GoRoute(
      path: '/items/:id/records',
      name: 'itemUsageRecords',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final name = state.uri.queryParameters['name'] ?? '物品';
        return SlideTransitionPage(
          child: UsageRecordsPage(itemId: id, itemName: name),
        );
      },
    ),
    GoRoute(
      path: '/items/:id',
      name: 'itemDetail',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: ItemDetailPage(id: int.parse(state.pathParameters['id']!)),
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
      path: '/notifications',
      name: 'notifications',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const NotificationCenterPage(),
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
    GoRoute(
      path: '/profile/edit',
      name: 'editProfile',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const EditProfilePage(),
      ),
    ),
    GoRoute(
      path: '/profile/panel',
      name: 'profilePanel',
      pageBuilder: (context, state) => SlideTransitionPage(
        child: const ProfilePanelPage(),
      ),
    ),
  ],
);
