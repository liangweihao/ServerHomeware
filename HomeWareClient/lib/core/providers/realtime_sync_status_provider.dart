import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WebSocket 实时同步连接状态
enum RealtimeSyncStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// 全局实时同步状态 — 供个人中心等展示
final realtimeSyncStatusProvider =
    StateProvider<RealtimeSyncStatus>((ref) => RealtimeSyncStatus.disconnected);
