import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/screens/family_screen.dart';
import 'package:app/screens/inventory_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/screens/item_list_screen.dart';

/// 主屏幕类，包含底部导航栏和四个主要页面
class HomeScreen extends StatefulWidget {
  /// 构造函数
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

/// 主屏幕状态类
class _HomeScreenState extends State<HomeScreen> {
  /// 当前选中的导航项索引
  int _currentIndex = 0;
  /// 导航栏对应的屏幕列表
  final List<Widget> _screens = [
    const ItemListScreen(),      // 物品列表屏幕
    const InventoryScreen(),     // 库存管理屏幕
    const FamilyScreen(),        // 家庭管理屏幕
    const ProfileScreen(),       // 个人资料屏幕
  ];

  @override
  void initState() {
    super.initState();
    // 初始化家庭列表数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
      familyProvider.getFamilies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家庭管理'),
        centerTitle: true,
      ),
      // 显示当前选中的屏幕
      body: _screens[_currentIndex],
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // 切换选中的导航项
          setState(() {
            _currentIndex = index;
          });
        },
        showUnselectedLabels: true,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: '物品',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: '库存',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '家庭',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
