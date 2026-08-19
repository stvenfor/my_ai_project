import 'package:module_core/model/realtime/realtime_connection_state.dart';
import 'package:module_core/model/realtime/realtime_envelope.dart';

/// 全局单连接 Realtime 客户端契约（直播信令 / 在线状态 / 全局通知）。
abstract class AppRealtimeClient {
  Stream<RealtimeConnectionState> get connectionState;

  RealtimeConnectionState get currentState;

  int get lastSeq;

  int get reconnectCount;

  int get outboundQueueDepth;

  bool get keepAliveInBackground;

  Future<void> connect();

  Future<void> disconnect({String? reason, bool clearQueue = false});

  Future<void> subscribeTopics(List<String> topics);

  Future<void> unsubscribeTopics(List<String> topics);

  Stream<RealtimeEnvelope> watchTopic(String topic);

  Stream<RealtimeEnvelope> watchEvents({String? eventName});

  Future<void> sendEvent({
    required String topic,
    required String eventName,
    Map<String, dynamic>? payload,
    bool requireAck = true,
  });

  /// 直播页等场景：App paused 时仍保持 WS。
  void setKeepAliveInBackground(bool enabled);
}
