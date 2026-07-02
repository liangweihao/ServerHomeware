import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 中文日期选择 — 统一 Material 日历弹窗
class AppDatePicker {
  AppDatePicker._();

  static const _zhLocale = Locale('zh', 'CN');

  /// 弹出日期选择器，返回选中日或 null
  static Future<DateTime?> show(
    BuildContext context, {
    required String title,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    final initial = initialDate ?? now;
    final first = firstDate ?? DateTime(2000);
    final last = lastDate ?? DateTime(2100);

    return showDatePicker(
      context: context,
      locale: _zhLocale,
      initialDate: initial.isBefore(first)
          ? first
          : (initial.isAfter(last) ? last : initial),
      firstDate: first,
      lastDate: last,
      helpText: title,
      cancelText: '取消',
      confirmText: '确定',
      fieldLabelText: '输入日期',
      fieldHintText: '年/月/日',
      errorFormatText: '日期格式无效',
      errorInvalidText: '日期超出范围',
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            datePickerTheme: DatePickerThemeData(
              headerHelpStyle: TextStyle(
                fontSize: 14,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// 格式化展示用日期
  static String formatDisplay(DateTime date) {
    return DateFormat('yyyy年M月d日', 'zh_CN').format(date);
  }
}
