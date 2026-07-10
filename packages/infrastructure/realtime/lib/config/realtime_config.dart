/// =============================================================================
/// 文件：realtime_config.dart
/// 作用：Realtime 模块的「开关与常量」集中配置
///
/// 【初学者】为什么用 static const 而不是读 .env？
///   心跳间隔、重连策略等与业务协议绑定，改频率需两端（Go/Flutter）一起评估；
///   放代码里版本可控。URL 类配置在 env_config / BackendWsConfig。
/// =============================================================================

/// Realtime 全局配置。
class RealtimeConfig {
  RealtimeConfig._();

  /// false = 连接真实 Go BFF；true = 进程内 Mock（无需后端，适合 UI 开发）。
  static const useMockGateway = false;

  /// HTTP 换票与 sync 的路径（相对 HttpManager 的 baseUrl）。
  static const ticketPath = '/api/v1/realtime/ws-ticket';
  static const syncPath = '/api/v1/realtime/sync';

  /// 应用层心跳：每 25s 发 ping，10s 内须收到同 id 的 pong。
  /// 为什么 25s？短于常见 NAT 超时，且不会过于频繁耗电。
  static const heartbeatInterval = Duration(seconds: 25);
  static const heartbeatTimeout = Duration(seconds: 10);
  /// 连续丢失 2 次才重连，避免一次抖动就断线。
  static const heartbeatMaxMiss = 2;

  /// 重连指数退避：1s → 2s → 4s … 上限 60s，加 20% 抖动防惊群。
  static const reconnectInitial = Duration(seconds: 1);
  static const reconnectMax = Duration(seconds: 60);
  static const reconnectMultiplier = 2.0;
  static const reconnectJitterRatio = 0.2;

  /// 客户端 sendEvent 后等待 ack 的最长时间，超时则标记失败并重试。
  static const outboundAckTimeout = Duration(seconds: 15);

  /// 通知 notifyId 去重队列最大长度。
  static const notifyDedupMax = 200;

  /// 顶部通知 Banner 自动消失时长。
  static const notifyBannerAutoDismiss = Duration(seconds: 4);

  /// 顶部通知 Banner 滑入/滑出动画时长。
  static const notifyBannerAnimation = Duration(milliseconds: 300);

  /// 与 Go entity.WSClose* 一致，用于判断是否需要重新换票。
  static const wsCloseAuthFailed = 4001;
  static const wsCloseKicked = 4002;
  static const wsCloseTicketExpired = 4003;
}

/// Topic 命名约定：与 Go entity.Topic* 字符串必须完全一致。
class RealtimeTopics {
  RealtimeTopics._();

  static const sysNotify = 'sys.notify';
  static String presenceUser(String userId) => 'presence.user.$userId';
  static const presenceBulk = 'presence.bulk';
  static String liveSignal(String roomId) => 'live.signal.$roomId';
  static String liveRoomState(String roomId) => 'live.room.$roomId.state';
}
