enum ImConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
}

extension ImConnectionStateX on ImConnectionState {
  String get label => switch (this) {
        ImConnectionState.disconnected => '未连接',
        ImConnectionState.connecting => '连接中',
        ImConnectionState.connected => '已连接',
        ImConnectionState.failed => '连接失败',
      };
}

class ImSessionInfo {
  const ImSessionInfo({
    required this.imUserId,
    required this.bizUserId,
    this.tokenExpiresAt,
  });

  final String imUserId;
  final String bizUserId;
  final DateTime? tokenExpiresAt;
}
