import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../common/widgets/app_button.dart';
import 'widgets/welcome_step.dart';
import 'widgets/room_select_step.dart';
import 'widgets/first_item_step.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingPage({super.key, required this.onComplete});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
    widget.onComplete();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 跳过按钮
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('跳过'),
              ),
            ),

            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  WelcomeStep(onNext: _nextPage),
                  RoomSelectStep(onNext: _nextPage, onBack: _previousPage),
                  FirstItemStep(onComplete: _completeOnboarding, onBack: _previousPage),
                ],
              ),
            ),

            // 页面指示器
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
