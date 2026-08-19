import 'dart:async';

import 'package:module_core/model/realtime/realtime_envelope.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/transport/ws_transport.dart';
import 'package:module_utils/module_utils.dart';

/// Mock WS 网关（进程内模拟 ping/pong/auth/sub/event）。
class MockWsTransport implements WsTransport {
  final _inbound = StreamController<RealtimeEnvelope>.broadcast();
  final Set<String> _topics = {};
  Timer? _mockPushTimer;
  int _seq = 0;
  bool _authed = false;
  String? _sessionId;

  @override
  Stream<RealtimeEnvelope> get inbound => _inbound.stream;

  @override
  bool get isConnected => _connected;
  bool _connected = false;

  @override
  Future<void> connect(Uri uri) async {
    await close();
    _connected = true;
    _authed = false;
    LogUtils.i('[MockWsTransport] connected uri=$uri');
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  @override
  Future<void> send(RealtimeEnvelope envelope) async {
    if (!_connected) throw StateError('Mock WS not connected');

    switch (envelope.type) {
      case 'auth':
        _authed = true;
        _sessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';
        _emit(
          RealtimeEnvelope(
            id: 'auth_ok_${DateTime.now().millisecondsSinceEpoch}',
            type: 'auth_ok',
            ts: DateTime.now().millisecondsSinceEpoch,
            payload: {
              'userId': 'mock_user',
              'sessionId': _sessionId,
              'serverTime': DateTime.now().millisecondsSinceEpoch,
            },
          ),
        );
      case 'ping':
        _emit(
          RealtimeEnvelope(
            id: envelope.id,
            type: 'pong',
            ts: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      case 'sub':
        final topics = envelope.payload['topics'];
        if (topics is List) {
          for (final t in topics) {
            _topics.add(t.toString());
          }
        }
        _emitAck(envelope.id, {'topics': _topics.toList()});
        _startMockPushIfNeeded();
      case 'unsub':
        final topics = envelope.payload['topics'];
        if (topics is List) {
          for (final t in topics) {
            _topics.remove(t.toString());
          }
        }
        _emitAck(envelope.id, {'topics': _topics.toList()});
        if (_topics.isEmpty) _mockPushTimer?.cancel();
      case 'event':
        _emitAck(envelope.id, {'accepted': true});
      default:
        LogUtils.d('[MockWsTransport] ignore outbound type=${envelope.type}');
    }
  }

  void _emitAck(String? refId, Map<String, dynamic> payload) {
    _emit(
      RealtimeEnvelope(
        id: 'ack_${DateTime.now().millisecondsSinceEpoch}',
        type: 'ack',
        ts: DateTime.now().millisecondsSinceEpoch,
        payload: {
          if (refId != null) 'refId': refId,
          ...payload,
        },
      ),
    );
  }

  void _startMockPushIfNeeded() {
    _mockPushTimer?.cancel();
    if (!_authed || _topics.isEmpty) return;

    _mockPushTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!_connected || !_authed) return;
      for (final topic in _topics) {
        _seq++;
        if (topic == RealtimeTopics.sysNotify) {
          _emit(
            RealtimeEnvelope(
              id: 'evt_notify_$_seq',
              type: 'event',
              topic: topic,
              seq: _seq,
              ts: DateTime.now().millisecondsSinceEpoch,
              payload: {
                'name': 'sys.notify.show',
                'notifyId': 'mock_notify_ws_$_seq',
                'title': 'Mock 全局通知',
                'body': 'seq=$_seq 来自 WS',
              },
            ),
          );
        } else if (topic.startsWith('live.signal.')) {
          _emit(
            RealtimeEnvelope(
              id: 'evt_live_$_seq',
              type: 'event',
              topic: topic,
              seq: _seq,
              ts: DateTime.now().millisecondsSinceEpoch,
              payload: {
                'name': 'live.seat_changed',
                'roomId': topic.replaceFirst('live.signal.', ''),
                'seatIndex': _seq % 4,
              },
            ),
          );
        } else if (topic.startsWith('presence.')) {
          _emit(
            RealtimeEnvelope(
              id: 'evt_presence_$_seq',
              type: 'event',
              topic: topic,
              seq: _seq,
              ts: DateTime.now().millisecondsSinceEpoch,
              payload: {
                'name': 'presence.update',
                'online': true,
                'count': 100 + _seq,
              },
            ),
          );
        }
      }
    });
  }

  void _emit(RealtimeEnvelope envelope) {
    if (!_inbound.isClosed) {
      _inbound.add(envelope);
    }
  }

  @override
  Future<void> close({int? code, String? reason}) async {
    _mockPushTimer?.cancel();
    _mockPushTimer = null;
    _connected = false;
    _authed = false;
    _topics.clear();
    LogUtils.i('[MockWsTransport] closed code=$code reason=$reason');
  }

  @override
  void dispose() {
    unawaited(close());
    unawaited(_inbound.close());
  }
}
