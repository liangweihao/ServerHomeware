import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../events/item_event_bus.dart';
import '../providers/alert_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import '../providers/home_provider.dart';
import '../providers/realtime_sync_status_provider.dart';
import '../services/api_service.dart';
import '../services/realtime_sync_service.dart';
import '../services/usage_record_sync_service.dart';

/// 实时同步控制器 — 管理 WebSocket 生命周期与防抖拉取
class RealtimeSyncController {
  RealtimeSyncController(this._ref) {
    _service = RealtimeSyncService(
      onEvent: _handleEvent,
      onStatusChanged: _setStatus,
    );
  }

  final Ref _ref;
  late final RealtimeSyncService _service;
  Timer? _debounceTimer;
  bool _syncInFlight = false;

  void _setStatus(RealtimeSyncStatus status) {
    _ref.read(realtimeSyncStatusProvider.notifier).state = status;
  }

  /// 登录后建立连接
  Future<void> connectIfAuthenticated() async {
    final authState = _ref.read(authProvider).valueOrNull;
    if (authState != AuthState.authenticated) {
      _setStatus(RealtimeSyncStatus.disconnected);
      await _service.disconnect();
      return;
    }

    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[RealtimeSyncController] WARN: 无 token，跳过连接');
      _setStatus(RealtimeSyncStatus.disconnected);
      return;
    }

    _setStatus(RealtimeSyncStatus.connecting);
    await _service.connect(token);
    if (_service.isConnected) {
      _setStatus(RealtimeSyncStatus.connected);
    }
  }

  /// 登出时断开
  Future<void> disconnect() async {
    _debounceTimer?.cancel();
    await _service.disconnect();
    _setStatus(RealtimeSyncStatus.disconnected);
  }

  /// 释放资源
  Future<void> dispose() async {
    _debounceTimer?.cancel();
    await _service.dispose();
  }

  Future<void> _handleEvent(String event, Map<String, dynamic> data) async {
    switch (event) {
      case 'items_changed':
      case 'usage_changed':
      case 'alerts_changed':
        _scheduleSync(data);
        break;
      default:
        debugPrint('[RealtimeSyncController] INFO: 忽略未知事件 $event');
    }
  }

  void _scheduleSync(Map<String, dynamic> data) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      unawaited(_performSync(data));
    });
  }

  Future<void> _performSync(Map<String, dynamic> data) async {
    if (_syncInFlight) return;
    _syncInFlight = true;

    try {
      final db = _ref.read(databaseProvider);
      debugPrint('[RealtimeSyncController] INFO: 开始防抖同步');

      // syncBidirectional 内已含物品同步 + usage 拉取/补推
      await UsageRecordSyncService(db).syncBidirectional();

      final itemIdRaw = data['item_id'];
      final itemId = itemIdRaw is int
          ? itemIdRaw
          : int.tryParse(itemIdRaw?.toString() ?? '');

      _ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: itemId);
      _ref.invalidate(homeStatsProvider);
      _ref.invalidate(unreadAlertCountProvider);
      _ref.invalidate(unreadNotificationsProvider);

      debugPrint('[RealtimeSyncController] INFO: 同步完成');
    } catch (error) {
      debugPrint('[RealtimeSyncController] WARN: 同步失败 $error');
    } finally {
      _syncInFlight = false;
    }
  }
}

/// 全局实时同步控制器
final realtimeSyncControllerProvider = Provider<RealtimeSyncController>((ref) {
  final controller = RealtimeSyncController(ref);
  ref.onDispose(() {
    unawaited(controller.dispose());
  });
  return controller;
});

/// 绑定认证状态与 WebSocket 生命周期
class RealtimeSyncBinder extends ConsumerStatefulWidget {
  const RealtimeSyncBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RealtimeSyncBinder> createState() => _RealtimeSyncBinderState();
}

class _RealtimeSyncBinderState extends ConsumerState<RealtimeSyncBinder> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncConnection());
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      next.whenData((state) {
        if (state == AuthState.authenticated) {
          unawaited(_syncConnection());
        } else {
          unawaited(ref.read(realtimeSyncControllerProvider).disconnect());
        }
      });
    });

    return widget.child;
  }

  Future<void> _syncConnection() async {
    await ref.read(realtimeSyncControllerProvider).connectIfAuthenticated();
  }
}
