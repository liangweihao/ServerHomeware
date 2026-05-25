import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

/// 欢迎引导页
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<WelcomePageData> _pages = const [
    WelcomePageData(
      emoji: '📦',
      title: '知道家里有什么',
      description: '扫一扫就能轻松记录每件物品',
    ),
    WelcomePageData(
      emoji: '📍',
      title: '知道东西在哪里',
      description: '再也不用翻箱倒柜找东西',
    ),
    WelcomePageData(
      emoji: '⏰',
      title: '知道什么时候该买',
      description: '过期提醒，智能补购',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 标记首次启动完成
  Future<void> _markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', false);
  }

  /// 跳转到登录页
  void _goToLogin() {
    _markFirstLaunchComplete();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      '跳过',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 主要内容
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _WelcomePageContent(
                    data: _pages[index],
                  );
                },
              ),
            ),
            // 底部
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // 页面指示器
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _DotIndicator(
                        isActive: index == _currentIndex,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 按钮
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentIndex < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _goToLogin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentIndex < _pages.length - 1 ? '下一步' : '开始使用',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
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

/// 欢迎页数据
class WelcomePageData {
  final String emoji;
  final String title;
  final String description;

  const WelcomePageData({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

/// 欢迎页内容
class _WelcomePageContent extends StatelessWidget {
  final WelcomePageData data;

  const _WelcomePageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 表情图标
          Text(
            data.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 48),
          // 标题
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: 12),
          // 描述
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.gray500,
                ),
          ),
        ],
      ),
    );
  }
}

/// 页面指示器
class _DotIndicator extends StatelessWidget {
  final bool isActive;

  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 24 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.gray300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
