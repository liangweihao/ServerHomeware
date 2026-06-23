import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_scheduler.dart';

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler();
});
