import 'package:flutter/foundation.dart' show debugPrint;
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

    const AndroidNotificationChannel inventoryChannel = AndroidNotificationChannel(
      'inventory_channel',
      '盘点提醒',
      description: '定期家庭库存盘点提醒',
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

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(inventoryChannel);
  }

  /// 固定通知 ID — 盘点提醒（不与物品 id 冲突）
  static const inventoryNotificationId = 900001;

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

  /// 调度每月盘点提醒（纯本地通知，无服务端）
  Future<void> scheduleInventoryReminder({required int dayOfMonth}) async {
    if (!_initialized) await initialize();

    await _notificationsPlugin.cancel(id: inventoryNotificationId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      dayOfMonth.clamp(1, 28),
      10,
      0,
    );
    if (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        dayOfMonth.clamp(1, 28),
        10,
        0,
      );
    }

    const androidDetails = AndroidNotificationDetails(
      'inventory_channel',
      '盘点提醒',
      channelDescription: '定期家庭库存盘点提醒',
      importance: Importance.defaultImportance,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _zonedScheduleSafe(
      id: inventoryNotificationId,
      title: '📋 该盘点家庭库存了',
      body: '每月核对一次，让账实更一致',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'inventory:task',
    );
  }

  /// 调度通知 — Android 12+ 无精确闹钟权限时降级为非精确
  Future<void> _zonedScheduleSafe({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    } catch (e) {
      debugPrint(
        '[NotificationScheduler] WARN: 精确闹钟不可用，降级 inexact: $e',
      );
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    }
  }

  Future<void> cancelInventoryReminder() async {
    if (!_initialized) await initialize();
    await _notificationsPlugin.cancel(id: inventoryNotificationId);
  }
}
