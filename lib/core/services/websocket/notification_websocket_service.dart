import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tivi_tea/core/services/local_storage/local_storage_impl.dart';
import 'package:tivi_tea/core/services/local_storage/storage_keys.dart';
import 'package:tivi_tea/core/utils/logger.dart';
import 'package:tivi_tea/features/notifications/model/notification_model.dart';
import 'package:tivi_tea/features/notifications/view_model/notifications_notifier.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'notification_websocket_service.g.dart';

const _wsNotificationsUrl = 'wss://api.tivitea.africa/ws/notifications/';

enum WebSocketConnectionStatus { disconnected, connecting, connected }

@Riverpod(keepAlive: true)
class NotificationWebSocketService
    extends _$NotificationWebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _disposed = false;

  @override
  WebSocketConnectionStatus build() {
    ref.onDispose(() {
      _disposed = true;
      disconnect();
    });
    return WebSocketConnectionStatus.disconnected;
  }

  /// Call this after a successful login to start the connection.
  void connect() {
    if (state == WebSocketConnectionStatus.connected) return;
    _reconnectAttempts = 0;
    _doConnect();
  }

  /// Disconnect and stop all reconnect timers.
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    if (!_disposed) {
      state = WebSocketConnectionStatus.disconnected;
    }
  }

  void _doConnect() {
    if (_disposed) return;

    final token =
        ref.read(localDB).get(HiveKeys.token) as String?;
    if (token == null || token.isEmpty) {
      debugLog('[WS] No token — skipping connection');
      _scheduleReconnect();
      return;
    }

    state = WebSocketConnectionStatus.connecting;
    debugLog('[WS] Connecting to notifications...');

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsNotificationsUrl),
        headers: {'Authorization': 'JWT $token'},
      );

      _reconnectAttempts = 0;
      state = WebSocketConnectionStatus.connected;
      debugLog('[WS] Connected');

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugLog('[WS] Stream error: $error');
          _scheduleReconnect();
        },
        onDone: () {
          debugLog('[WS] Connection closed');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugLog('[WS] Connection failed: $e');
      _scheduleReconnect();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final notification = NotificationModel.fromJson(json);
      ref
          .read(notificationsNotifierProvider.notifier)
          .prependNotification(notification);
      debugLog('[WS] New notification: ${notification.title}');
    } catch (e) {
      debugLog('[WS] Failed to parse message: $e');
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectTimer != null) return;
    if (!_disposed) state = WebSocketConnectionStatus.disconnected;
    _channel = null;
    final delay = _nextDelay();
    debugLog('[WS] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      _doConnect();
    });
  }

  Duration _nextDelay() {
    _reconnectAttempts++;
    // Exponential backoff: 2s, 4s, 8s, 16s, 32s, 60s max
    final seconds = min(2 * pow(2, min(_reconnectAttempts - 1, 4)).toInt(), 60);
    return Duration(seconds: seconds);
  }
}
