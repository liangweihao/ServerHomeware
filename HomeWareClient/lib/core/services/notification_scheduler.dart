import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../data/database/app_database.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notificationsPlugin.initialize(
      settings: InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
      ),
    );

    await _createNotificationChannels();

    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel expiryChannel = AndroidNotificationChannel(
      'expiry_channel',
      '过期提醒',
      description: '物品过期提醒',
      importance: Importance.high,
    );

    const AndroidNotificationChannel stockChannel = AndroidNotificationChannel(
      'stock_channel',
      '库存提醒',
      description: '库存不足提醒',
      importance: Importance.defaultImportance,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(expiryChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(stockChannel);
  }

  Future<void> scheduleExpiryNotification(Item item) async {
    if (!_initialized) await initialize();

    final expiryDate = item.expiryDate;
    if (expiryDate == null) return;

    final alertDate =
        expiryDate.subtract(Duration(days: item.expiryAlertDays));
    final now = DateTime.now();

    if (alertDate.isBefore(now)) return;

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      alertDate,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      '过期提醒',
      channelDescription: '物品即将过期提醒',
      importance: Importance.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: item.id,
      title: '⚠️ 物品即将过期',
      body: '${item.name} 将在${item.expiryAlertDays}天后过期，请及时处理',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'item:${item.id}',
    );
  }

  Future<void> cancelNotification(int itemId) async {
    if (!_initialized) await initialize();
    await _notificationsPlugin.cancel(id: itemId);
  }

  Future<void> rescheduleAllNotifications(AppDatabase db) async {
    if (!_initialized) await initialize();

    await _notificationsPlugin.cancelAll();

    final items = await db.getAllItems();
    for (final item in items) {
      if (item.status == 0 && item.expiryDate != null) {
        await scheduleExpiryNotification(item);
      }
    }
  }

  Future<void> checkAndUpdateExpiredItems(AppDatabase db) async {
    final items = await db.getAllItems();
    final today = DateTime.now();

    for (final item in items) {
      final expiryDate = item.expiryDate;
      if (item.status == 0 &&
          expiryDate != null &&
          expiryDate.isBefore(today)) {
        await db.updateItem(item.copyWith(status: 2));
        await cancelNotification(item.id);
      }
    }
  }
}
