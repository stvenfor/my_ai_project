/// 全局 WS 连接状态。
enum RealtimeConnectionState {
  disconnected,
  connecting,
  authenticating,
  connected,
  reconnecting,
  degraded,
  failed,
}

extension RealtimeConnectionStateX on RealtimeConnectionState {
  bool get isActive =>
      this == RealtimeConnectionState.connected ||
      this == RealtimeConnectionState.degraded;

  String get label => switch (this) {
        RealtimeConnectionState.disconnected => '未连接',
        RealtimeConnectionState.connecting => '连接中',
        RealtimeConnectionState.authenticating => '鉴权中',
        RealtimeConnectionState.connected => '已连接',
        RealtimeConnectionState.reconnecting => '重连中',
        RealtimeConnectionState.degraded => '降级',
        RealtimeConnectionState.failed => '失败',
      };
}
