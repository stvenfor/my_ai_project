import 'dart:async';

import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_utils/module_utils.dart';

typedef HeartbeatSend = Future<void> Function(String pingId);
typedef HeartbeatTimeout = void Function();

/// 应用层 ping/pong 调度。
class HeartbeatScheduler {
  HeartbeatScheduler({
    required HeartbeatSend onSendPing,
    required HeartbeatTimeout onTimeout,
  })  : _onSendPing = onSendPing,
        _onTimeout = onTimeout;

  final HeartbeatSend _onSendPing;
  final HeartbeatTimeout _onTimeout;

  Timer? _intervalTimer;
  Timer? _timeoutTimer;
  int _missCount = 0;
  String? _pendingPingId;

  void start() {
    stop();
    _scheduleNext();
  }

  void stop() {
    _intervalTimer?.cancel();
    _timeoutTimer?.cancel();
    _intervalTimer = null;
    _timeoutTimer = null;
    _missCount = 0;
    _pendingPingId = null;
  }

  void onPong(String pingId) {
    if (_pendingPingId != pingId) return;
    _timeoutTimer?.cancel();
    _pendingPingId = null;
    _missCount = 0;
  }

  void _scheduleNext() {
    _intervalTimer?.cancel();
    _intervalTimer = Timer(RealtimeConfig.heartbeatInterval, _firePing);
  }

  Future<void> _firePing() async {
    final pingId = 'ping_${DateTime.now().millisecondsSinceEpoch}';
    _pendingPingId = pingId;
    try {
      await _onSendPing(pingId);
    } catch (e, st) {
      LogUtils.w('[Realtime] heartbeat send failed', e, st);
    }

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(RealtimeConfig.heartbeatTimeout, () {
      _missCount++;
      LogUtils.w('[Realtime] heartbeat timeout miss=$_missCount pingId=$pingId');
      if (_missCount >= RealtimeConfig.heartbeatMaxMiss) {
        _onTimeout();
        return;
      }
      _pendingPingId = null;
      _scheduleNext();
    });

    _scheduleNext();
  }
}
