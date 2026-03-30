import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/family_provider.dart';
import 'package:app/screens/family_screen.dart';
import 'package:app/screens/inventory_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/screens/item_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ItemListScreen(),
    const InventoryScreen(),
    const FamilyScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化家庭列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final familyProvider = Provider.of<FamilyProvider>(context, listen: false);
      familyProvider.getFamilies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('家庭物品管理'),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
