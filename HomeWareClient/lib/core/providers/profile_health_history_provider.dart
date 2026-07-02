import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/profile_health_history_service.dart';

/// 健康分历史曲线数据
final profileHealthHistoryProvider =
    FutureProvider<List<ProfileHealthSnapshot>>((ref) async {
  return ProfileHealthHistoryService.load();
});
