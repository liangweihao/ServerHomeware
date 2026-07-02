import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// 清爽工具风通用 Scaffold
class WarmScaffold extends StatelessWidget {
  const WarmScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.leading,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? leading;

  /// AppBar 底部（如 TabBar）
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.appBarForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: leading,
        title: titleWidget ?? (title != null ? Text(title!) : null),
        actions: actions,
        bottom: bottom ??
            PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(
                height: 0.5,
                color: AppColors.homeDivider,
              ),
            ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
