import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

/// 统一错误处理：logcat 打印详细错误 + Toast 显示用户友好提示
///
/// 用法：
/// ```dart
/// } catch (e, stack) {
///   ErrorHandler.handle(
///     context,
///     e,
///     stack,
///     label: '[EditProfilePage] 保存资料',
///     userMessage: '保存失败，请稍后重试',
///   );
/// }
/// ```
class ErrorHandler {
  /// 处理异常：打日志 + 弹 toast（仅在 mounted 时弹 toast）
  static void handle(
    BuildContext context,
    Object e,
    StackTrace stack, {
    String label = '',
    String userMessage = '操作失败，请稍后重试',
  }) {
    // 详细日志（含调用位置 + 完整堆栈）
    debugPrint('$label 异常: $e');
    debugPrint('$label 堆栈: $stack');

    // 用户友好 toast
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
