/// Realtime 全局配置。
class RealtimeConfig {
  RealtimeConfig._();

  /// false=连接 Go BFF WebSocket 网关；true=进程内 Mock。
  static const useMockGateway = false;

  static const ticketPath = '/api/v1/realtime/ws-ticket';
  static const syncPath = '/api/v1/realtime/sync';

  static const heartbeatInterval = Duration(seconds: 25);
  static const heartbeatTimeout = Duration(seconds: 10);
  static const heartbeatMaxMiss = 2;

  static const reconnectInitial = Duration(seconds: 1);
  static const reconnectMax = Duration(seconds: 60);
  static const reconnectMultiplier = 2.0;
  static const reconnectJitterRatio = 0.2;

  static const outboundAckTimeout = Duration(seconds: 15);
  static const notifyDedupMax = 200;

  static const wsCloseAuthFailed = 4001;
  static const wsCloseKicked = 4002;
  static const wsCloseTicketExpired = 4003;
}

/// Topic 命名约定。
class RealtimeTopics {
  RealtimeTopics._();

  static const sysNotify = 'sys.notify';
  static String presenceUser(String userId) => 'presence.user.$userId';
  static const presenceBulk = 'presence.bulk';
  static String liveSignal(String roomId) => 'live.signal.$roomId';
  static String liveRoomState(String roomId) => 'live.room.$roomId.state';
}
