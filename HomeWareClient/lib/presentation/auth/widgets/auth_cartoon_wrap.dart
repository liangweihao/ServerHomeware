import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../common/widgets/app_card.dart';
import '../../common/widgets/cartoon_ui.dart';

/// Auth 流程表单区 — 工具风 AppCard / 卡通 AppSurface 双分支
Widget wrapAuthFormSurface({
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  final pad = padding ?? const EdgeInsets.all(20);

  if (AppColors.isUtilityStyle) {
    return AppCard(padding: pad, child: child);
  }

  return AppSurface(
    padding: pad,
    child: child,
  );
}

/// Auth 页标题 — 工具风纯文字，卡通主题带 emoji
String authPageTitle(String title, {String? emoji}) {
  if (AppColors.isUtilityStyle) return title;
  if (emoji == null || emoji.isEmpty) return title;
  return CartoonUi.pageTitle(title, emoji: emoji);
}
