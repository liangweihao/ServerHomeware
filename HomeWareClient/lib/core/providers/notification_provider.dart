import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_scheduler.dart';
import 'database_provider.dart';

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler();
});

final alertCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  
  final expiryAlerts = await db.getExpiryAlerts();
  final stockAlerts = await db.getStockAlerts();
  final restockAlerts = await db.getRestockAlerts();
  final warrantyAlerts = await db.getWarrantyAlerts();
  
  return expiryAlerts.length + stockAlerts.length + restockAlerts.length + warrantyAlerts.length;
});
