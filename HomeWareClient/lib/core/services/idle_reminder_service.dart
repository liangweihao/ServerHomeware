import 'package:flutter/foundation.dart' show debugPrint;

import 'api_service.dart';

/// 拉取服务端 idle 通知文案，供通知中心 / 提醒卡覆盖本地默认描述。
///
/// 产品策略：本地 `getIdleAlerts()` 负责「哪些物品要提醒」（离线可用），
/// 服务端 Celery + AI 生成的 `body` 在有网时覆盖展示文案。
class IdleReminderService {
  /// 返回 Map：服务端 item_id → AI 提醒文案
  Future<Map<int, String>> fetchIdleBodiesByServerItemId() async {
    try {
      final json = await ApiService.get(
        '/notifications?type=idle&page_size=100',
      );
      if (json['code'] != 200) {
        debugPrint(
          '[IdleReminder] WARN: 拉取失败 code=${json['code']} msg=${json['message']}',
        );
        return {};
      }

      final data = json['data'];
      final rawItems = data is Map ? data['items'] : null;
      if (rawItems is! List) return {};

      final result = <int, String>{};
      for (final row in rawItems) {
        if (row is! Map) continue;
        final itemId = row['item_id'];
        final body = row['body']?.toString().trim() ?? '';
        final id = itemId is int
            ? itemId
            : int.tryParse(itemId?.toString() ?? '');
        if (id == null || body.isEmpty) continue;
        // 同物品多条时保留最新（接口默认按创建时间，后者覆盖）
        result[id] = body;
      }
      debugPrint('[IdleReminder] INFO: 同步 idle 文案 ${result.length} 条');
      return result;
    } catch (e) {
      debugPrint('[IdleReminder] WARN: 同步异常 $e');
      return {};
    }
  }
}
