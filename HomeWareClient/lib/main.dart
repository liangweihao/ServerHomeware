import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_scheduler.dart';
import 'core/services/inventory_reminder_prefs.dart';
import 'data/database/app_database.dart';
import 'core/providers/auth_guard.dart';
import 'presentation/common/widgets/app_theme_background.dart';

/// 全局错误观察者 - 监听 Provider 错误
class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(ProviderBase<Object?> provider, Object error, StackTrace stackTrace, ProviderContainer container) {
    // 记录错误日志
    debugPrint('═══════════════════════════════════════════');
    debugPrint('Provider Error: ${provider.name ?? provider.runtimeType}');
    debugPrint('Error: $error');
    debugPrint('StackTrace: $stackTrace');
    debugPrint('═══════════════════════════════════════════');
  }
}

void main() async {
  // 初始化 WidgetsFlutterBinding
  WidgetsFlutterBinding.ensureInitialized();

  // Windows/Linux 桌面端用 FFI 初始化 sqflite
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 设置中文区域
  Intl.defaultLocale = 'zh_CN';
  
  // 初始化日期格式化的区域设置数据
  await initializeDateFormatting('zh_CN');

  // 初始化数据库并插入预设数据
  final db = AppDatabase();
  await db.ensureInitialized();

  // 初始化通知服务和相关任务
  final notificationScheduler = NotificationScheduler();
  await notificationScheduler.initialize();
  
  // 每日检查任务：检查过期物品并更新状态
  notificationScheduler.checkAndUpdateExpiredItems(db).catchError((error) {
    debugPrint('Check expired items error: $error');
  });
  
  // 重新调度所有通知
  notificationScheduler.rescheduleAllNotifications(db).catchError((error) {
    debugPrint('Reschedule notifications error: $error');
  });

  // 盘点提醒（纯本地，默认开启）
  InventoryReminderPrefs.isEnabled().then((enabled) async {
    if (enabled) {
      final day = await InventoryReminderPrefs.dayOfMonth();
      await notificationScheduler.scheduleInventoryReminder(dayOfMonth: day);
    }
  }).catchError((error) {
    debugPrint('Schedule inventory reminder error: $error');
  });

  // 启动前加载主题，避免首帧颜色闪烁
  final initialTheme = await loadInitialThemeVariant();

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      overrides: [
        initialThemeVariantProvider.overrideWithValue(initialTheme),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeVariant = ref.watch(appThemeVariantProvider);

    return MaterialApp.router(
      title: 'HomeStock',
      theme: AppTheme.lightThemeOf(themeVariant),
      routerConfig: appRouter,
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppThemeBackground(
        child: AuthGuard(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
