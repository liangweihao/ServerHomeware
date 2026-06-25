import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'cartoon_ui.dart';

/// 卡通页面脚手架 — 统一 AppBar 标题/背景/FAB
class CartoonScaffold extends StatelessWidget {
  const CartoonScaffold({
    super.key,
    this.title,
    this.titleEmoji,
    this.titleWidget,
    this.actions,
    this.bottom,
    this.leading,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
  });

  final String? title;
  final String? titleEmoji;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    Widget? appBarTitle = titleWidget;
    if (appBarTitle == null && title != null) {
      appBarTitle = Text(
        CartoonUi.pageTitle(title!, emoji: titleEmoji),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      );
    }

    final hasAppBar =
        appBarTitle != null || actions != null || bottom != null || leading != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBody: extendBody,
      appBar: hasAppBar
          ? AppBar(
              backgroundColor: AppColors.appBarBackground,
              elevation: 0,
              leading: leading,
              title: appBarTitle,
              actions: actions,
              bottom: bottom,
            )
          : null,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
