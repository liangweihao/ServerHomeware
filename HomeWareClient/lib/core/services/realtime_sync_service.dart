import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/app_env.dart';
import '../providers/realtime_sync_status_provider.dart';

/// WebSocket 实时事件回调
typedef RealtimeEventHandler = Future<void> Function(
  String event,
  Map<String, dynamic> data,
);

/// 连接状态变化回调
typedef RealtimeStatusHandler = void Function(RealtimeSyncStatus status);

/// WebSocket 实时同步服务 — 连接服务端 `/ws/notifications`
class RealtimeSyncService {
  RealtimeSyncService({
    required this.onEvent,
    this.onStatusChanged,
  });

  final RealtimeEventHandler onEvent;
  final RealtimeStatusHandler? onStatusChanged;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  String? _token;
  bool _disposed = false;
  bool _connecting = false;
  int _reconnectAttempt = 0;

  static const _maxReconnectDelay = Duration(seconds: 30);
  static const _baseReconnectDelay = Duration(seconds: 2);
  static const _handshakeTimeout = Duration(seconds: 10);

  /// 是否已连接（握手完成）
  bool get isConnected => _channel != null && _subscription != null;

  /// 建立 WebSocket 连接
  Future<void> connect(String token) async {
    if (_disposed || _connecting) return;
    if (token.isEmpty) {
      debugPrint('[RealtimeSync] WARN: token 为空，跳过连接');
      return;
    }

    if (_token == token && isConnected) {
      return;
    }

    _connecting = true;
    await _closeChannel(resetToken: false);
    _token = token;

    final uri = AppEnv.wsNotificationsUri(token);
    debugPrint('[RealtimeSync] INFO: 连接 $uri');

    WebSocketChannel? channel;
    try {
      channel = await _openChannel(uri).timeout(_handshakeTimeout);
      _channel = channel;
      _reconnectAttempt = 0;

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleStreamError,
        onDone: _handleStreamDone,
        cancelOnError: true,
      );
      onStatusChanged?.call(RealtimeSyncStatus.connected);
      debugPrint('[RealtimeSync] INFO: 握手成功');
    } on Object catch (error, stackTrace) {
      debugPrint('[RealtimeSync] ERROR: 连接失败 $error');
      debugPrint('[RealtimeSync] ERROR: $stackTrace');
      await _safeCloseChannel(channel);
      onStatusChanged?.call(RealtimeSyncStatus.reconnecting);
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  /// 主动断开连接
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _closeChannel(resetToken: true);
    debugPrint('[RealtimeSync] INFO: 已断开');
  }

  /// 释放资源（登出时调用）
  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
  }

  /// 建立底层 WebSocket 通道（握手失败在此抛出，避免未捕获异常）
  Future<WebSocketChannel> _openChannel(Uri uri) async {
    if (kIsWeb) {
      return WebSocketChannel.connect(uri);
    }

    final socket = await WebSocket.connect(
      uri.toString(),
      headers: const {'Connection': 'upgrade'},
    );
    return IOWebSocketChannel(socket);
  }

  void _handleMessage(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String);
      if (decoded is! Map<String, dynamic>) return;

      final event = decoded['event']?.toString() ?? '';
      if (event == 'ping') {
        _sendPong();
        return;
      }

      final dataRaw = decoded['data'];
      final data = dataRaw is Map<String, dynamic>
          ? dataRaw
          : <String, dynamic>{};

      debugPrint('[RealtimeSync] INFO: 收到事件 event=$event data=$data');
      unawaited(onEvent(event, data));
    } catch (error) {
      debugPrint('[RealtimeSync] WARN: 消息解析失败 $error raw=$raw');
    }
  }

  void _sendPong() {
    try {
      _channel?.sink.add(jsonEncode({'event': 'pong'}));
    } catch (error) {
      debugPrint('[RealtimeSync] WARN: pong 发送失败 $error');
    }
  }

  void _handleStreamError(Object error, StackTrace stackTrace) {
    debugPrint('[RealtimeSync] ERROR: 连接异常 $error');
    onStatusChanged?.call(RealtimeSyncStatus.reconnecting);
    unawaited(_closeChannel(resetToken: false));
    _scheduleReconnect();
  }

  void _handleStreamDone() {
    debugPrint('[RealtimeSync] WARN: 连接关闭');
    onStatusChanged?.call(RealtimeSyncStatus.reconnecting);
    unawaited(_closeChannel(resetToken: false));
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed || _token == null) return;

    onStatusChanged?.call(RealtimeSyncStatus.reconnecting);

    _reconnectTimer?.cancel();
    final delay = _nextReconnectDelay();
    debugPrint('[RealtimeSync] INFO: ${delay.inSeconds}s 后重连');
    _reconnectTimer = Timer(delay, () {
      final token = _token;
      if (token != null && !_disposed) {
        unawaited(connect(token));
      }
    });
  }

  Duration _nextReconnectDelay() {
    _reconnectAttempt += 1;
    final seconds = _baseReconnectDelay.inSeconds * _reconnectAttempt;
    final capped = seconds > _maxReconnectDelay.inSeconds
        ? _maxReconnectDelay.inSeconds
        : seconds;
    return Duration(seconds: capped);
  }

  Future<void> _closeChannel({required bool resetToken}) async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    await _safeCloseChannel(_channel);
    _channel = null;
    if (resetToken) {
      _token = null;
    }
  }

  Future<void> _safeCloseChannel(WebSocketChannel? channel) async {
    if (channel == null) return;
    try {
      await channel.sink.close();
    } catch (error) {
      debugPrint('[RealtimeSync] WARN: 关闭连接失败 $error');
    }
  }
}
