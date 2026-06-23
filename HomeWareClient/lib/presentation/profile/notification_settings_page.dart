import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

// Notification settings providers
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final defaultAlertDaysProvider = StateProvider<int>((ref) => 3);
final notificationStartHourProvider = StateProvider<int>((ref) => 8);
final notificationEndHourProvider = StateProvider<int>((ref) => 22);

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(notificationsEnabledProvider.notifier).state = prefs.getBool('notifications_enabled') ?? true;
    ref.read(defaultAlertDaysProvider.notifier).state = prefs.getInt('default_alert_days') ?? 3;
    ref.read(notificationStartHourProvider.notifier).state = prefs.getInt('notification_start_hour') ?? 8;
    ref.read(notificationEndHourProvider.notifier).state = prefs.getInt('notification_end_hour') ?? 22;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', ref.read(notificationsEnabledProvider));
    await prefs.setInt('default_alert_days', ref.read(defaultAlertDaysProvider));
    await prefs.setInt('notification_start_hour', ref.read(notificationStartHourProvider));
    await prefs.setInt('notification_end_hour', ref.read(notificationEndHourProvider));
  }

  @override
  Widget build(BuildContext context) {
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final defaultAlertDays = ref.watch(defaultAlertDaysProvider);
    final startHour = ref.watch(notificationStartHourProvider);
    final endHour = ref.watch(notificationEndHourProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        title: const Text('提醒设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 全局开关
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Material(
              color: Colors.transparent,
              child: SwitchListTile(
                title: const Text('开启通知'),
                subtitle: const Text('接收物品过期和库存不足提醒'),
                value: notificationsEnabled,
                onChanged: (value) {
                  ref.read(notificationsEnabledProvider.notifier).state = value;
                  _saveSettings();
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 过期提醒提前天数
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('过期提醒默认提前天数'),
                subtitle: Text('提前 $defaultAlertDays 天提醒'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAlertDaysDialog(context, defaultAlertDays),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 提醒时间段
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('提醒时间段'),
                subtitle: Text('${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTimeRangeDialog(context, startHour, endHour),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 提示文字
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '仅在设置的时间段内推送通知，\n避免打扰您的休息。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertDaysDialog(BuildContext context, int currentDays) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedDays = currentDays;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('过期提醒提前天数'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('设置默认提前几天提醒您'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selectedDays > 1
                          ? () => setState(() => selectedDays--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text(
                        '$selectedDays',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: selectedDays < 30
                          ? () => setState(() => selectedDays++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const Text('天'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(defaultAlertDaysProvider.notifier).state = selectedDays;
                  _saveSettings();
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimeRangeDialog(BuildContext context, int startHour, int endHour) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedStart = startHour;
        int selectedEnd = endHour;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('提醒时间段'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('设置允许接收提醒的时间段'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('开始时间'),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: selectedStart,
                            items: List.generate(24, (i) => i)
                                .map((h) => DropdownMenuItem(
                                      value: h,
                                      child: Text('${h.toString().padLeft(2, '0')}:00'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedStart = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const Text(' 至 '),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('结束时间'),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: selectedEnd,
                            items: List.generate(24, (i) => i)
                                .map((h) => DropdownMenuItem(
                                      value: h,
                                      child: Text('${h.toString().padLeft(2, '0')}:00'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedEnd = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  if (selectedEnd <= selectedStart) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('结束时间必须晚于开始时间')),
                    );
                    return;
                  }
                  ref.read(notificationStartHourProvider.notifier).state = selectedStart;
                  ref.read(notificationEndHourProvider.notifier).state = selectedEnd;
                  _saveSettings();
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          ),
        );
      },
    );
  }
}
