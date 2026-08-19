import 'dart:async';
import 'dart:convert';

import 'package:module_core/model/realtime/realtime_envelope.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/transport/ws_transport.dart';
import 'package:module_utils/module_utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// 真实 WebSocket 传输（[RealtimeConfig.useMockGateway]=false 时使用）。
class WebSocketTransport implements WsTransport {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final _inbound = StreamController<RealtimeEnvelope>.broadcast();

  @override
  Stream<RealtimeEnvelope> get inbound => _inbound.stream;

  @override
  bool get isConnected => _channel != null;

  @override
  Future<void> connect(Uri uri) async {
    await close();
    LogUtils.i('[WebSocketTransport] connect uri=$uri');
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          _inbound.add(RealtimeEnvelope.fromJson(json));
        } catch (e, st) {
          LogUtils.e('[WebSocketTransport] parse error', e, st);
        }
      },
      onError: (e, st) {
        LogUtils.w('[WebSocketTransport] stream error', e, st);
        _inbound.addError(e, st);
      },
      onDone: () => _inbound.addError(const WebSocketTransportClosed()),
    );
  }

  @override
  Future<void> send(RealtimeEnvelope envelope) async {
    final channel = _channel;
    if (channel == null) throw StateError('WebSocket not connected');
    channel.sink.add(jsonEncode(envelope.toJson()));
  }

  @override
  Future<void> close({int? code, String? reason}) async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close(code ?? 1000, reason);
    _channel = null;
  }

  @override
  void dispose() {
    unawaited(close());
    unawaited(_inbound.close());
  }
}

class WebSocketTransportClosed implements Exception {
  const WebSocketTransportClosed();
}
