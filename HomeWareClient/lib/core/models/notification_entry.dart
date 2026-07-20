import '../../data/database/app_database.dart';

/// 通知中心列表条目（物品 + 提醒类型 + 紧急度 + 位置路径）
class NotificationEntry {
  final Item item;
  final String alertTypeKey;
  final int urgency;
  /// 展示用位置路径，如「厨房 › 冰箱」
  final String? locationPath;
  /// 服务端 AI 文案覆盖（idle 等）；为空则用本地默认 description
  final String? descriptionOverride;

  const NotificationEntry({
    required this.item,
    required this.alertTypeKey,
    required this.urgency,
    this.locationPath,
    this.descriptionOverride,
  });
}
