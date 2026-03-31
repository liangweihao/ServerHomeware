import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/providers/item_provider.dart';
import 'package:app/screens/login_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/family_screen.dart';
import 'package:app/screens/inventory_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/screens/item_list_screen.dart';
import 'package:app/screens/add_item_screen.dart';
import 'package:app/screens/item_detail_screen.dart';
import 'package:app/screens/register_screen.dart';
import 'package:app/services/api_service.dart';

/// 应用程序入口点
void main() {
  runApp(const MyApp());
}

/// 应用程序主类
class MyApp extends StatelessWidget {
  /// 构造函数
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 创建全局导航键
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    // 设置ApiService的全局导航键
    ApiService.setNavigatorKey(navigatorKey);

    return MultiProvider(
      /// 注册全局状态管理提供者
      providers: [
        /// 认证状态提供者
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        /// 家庭状态提供者
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        /// 物品状态提供者
        ChangeNotifierProvider(create: (_) => ItemProvider()),
      ],
      child: MaterialApp(
        /// 全局导航键
        navigatorKey: navigatorKey,
        /// 应用主题
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        /// 初始路由
        initialRoute: '/',
        /// 路由配置
        routes: {
          /// 登录屏幕
          '/': (context) => const LoginScreen(),
          /// 主屏幕
          '/home': (context) => const HomeScreen(),
          /// 家庭管理屏幕
          '/family': (context) => const FamilyScreen(),
          /// 库存管理屏幕
          '/inventory': (context) => const InventoryScreen(),
          /// 个人资料屏幕
          '/profile': (context) => const ProfileScreen(),
          /// 物品列表屏幕
          '/items': (context) => const ItemListScreen(),
          /// 添加物品屏幕
          '/add-item': (context) => const AddItemScreen(),
          /// 注册屏幕
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}
