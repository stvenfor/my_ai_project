/// Realtime 全局配置。
class RealtimeConfig {
  RealtimeConfig._();

  /// 无真实 WS 网关时使用 Mock Transport + Mock Ticket/Sync API。
  static const useMockGateway = true;

  static const ticketPath = '/realtime/ws-ticket';
  static const syncPath = '/realtime/sync';

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
