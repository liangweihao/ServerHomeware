import 'package:flutter/material.dart';
import '../../../core/theme/app_decorations.dart';

/// Auth 流程表单区 — AppSurface 贴纸卡片包裹
Widget wrapAuthFormSurface({
  required Widget child,
  EdgeInsetsGeometry? padding,
}) {
  return AppSurface(
    padding: padding ?? const EdgeInsets.all(20),
    child: child,
  );
}
