import 'dart:async';

import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_utils/module_utils.dart';

typedef HeartbeatSend = Future<void> Function(String pingId);
typedef HeartbeatTimeout = void Function();

/// =============================================================================
/// 应用层 ping/pong 调度器
///
/// 【为什么需要应用层心跳，Go 不是已经发协议 Ping 了吗？】
///   协议 Ping 对 Flutter 透明，业务层无法感知 RTT 或主动触发重连；
///   应用 ping/pong 让客户端在 2 次超时后走统一的 reconnect 流程（含 sync）。
/// =============================================================================
class HeartbeatScheduler {
  HeartbeatScheduler({
    required HeartbeatSend onSendPing,
    required HeartbeatTimeout onTimeout,
  })  : _onSendPing = onSendPing,
        _onTimeout = onTimeout;

  final HeartbeatSend _onSendPing;
  final HeartbeatTimeout _onTimeout;

  Timer? _intervalTimer; // 定时触发 ping
  Timer? _timeoutTimer;  // 等待 pong 的超时
  int _missCount = 0;
  String? _pendingPingId; // 当前等待 pong 的 ping id

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

  /// 收到 pong 时调用：id 必须匹配 pendingPingId 才计数清零。
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

    // 启动 pong 超时计时
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(RealtimeConfig.heartbeatTimeout, () {
      _missCount++;
      LogUtils.w('[Realtime] heartbeat timeout miss=$_missCount pingId=$pingId');
      if (_missCount >= RealtimeConfig.heartbeatMaxMiss) {
        _onTimeout(); // 通知 AppRealtimeClient 重连
        return;
      }
      _pendingPingId = null;
      _scheduleNext();
    });

    // 不等待 pong 也 schedule 下一次 ping（并行等待超时）
    _scheduleNext();
  }
}
