import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_scheduler.dart';
import 'data/database/app_database.dart';

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

  // 设置中文区域
  Intl.defaultLocale = 'zh_CN';

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

  runApp(
    ProviderScope(
      observers: [AppProviderObserver()],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HomeStock',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      locale: const Locale('zh', 'CN'),
      debugShowCheckedModeBanner: false,
    );
  }
}
