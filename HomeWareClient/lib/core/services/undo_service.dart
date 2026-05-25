import 'package:flutter/material.dart';

/// 撤销服务 - 提供删除后撤销功能
class UndoService {
  static final UndoService _instance = UndoService._internal();
  factory UndoService() => _instance;
  UndoService._internal();

  /// 显示删除 SnackBar 并在超时后执行确认删除
  /// 返回一个可以在超时前调用的取消函数
  void showDeleteSnackBar({
    required BuildContext context,
    required String title,
    required String itemName,
    required VoidCallback onConfirm,
    VoidCallback? onUndo,
    Duration duration = const Duration(seconds: 5),
  }) {
    // 先显示 SnackBar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除「$itemName」'),
        duration: duration,
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            onUndo?.call();
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
