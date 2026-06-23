import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/alert_provider.dart';


class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
    return WillPopScope(
      onWillPop: () async {
        if (_isMainRoute()) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: Consumer(
          builder: (context, ref, child) {
            final alertCountAsync = ref.watch(unreadAlertCountProvider);
            final alertCount = alertCountAsync.value ?? 0;
            
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '首页',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: '物品',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: alertCount > 0 ? Text(alertCount.toString()) : null,
                    isLabelVisible: alertCount > 0,
                    child: const Icon(Icons.notifications),
                  ),
                  label: '提醒',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: '我的',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}