import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/session/session_guard.dart';
import 'package:module_auth/session/session_recovery.dart';
import 'package:module_core/core.dart';
import 'package:module_core/model/realtime/realtime_connection_state.dart';
import 'package:module_core/model/realtime/realtime_envelope.dart';
import 'package:module_core/service/app_realtime_client.dart';
import 'package:module_http/module_http.dart';
import 'package:module_realtime/api/ws_sync_api.dart';
import 'package:module_realtime/api/ws_ticket_api.dart';
import 'package:module_realtime/config/realtime_config.dart';
import 'package:module_realtime/connection/heartbeat_scheduler.dart';
import 'package:module_realtime/connection/reconnect_policy.dart';
import 'package:module_realtime/handlers/global_notify_handler.dart';
import 'package:module_realtime/queue/outbound_queue_manager.dart';
import 'package:module_realtime/router/inbound_router.dart';
import 'package:module_realtime/store/realtime_seq_store.dart';
import 'package:module_realtime/telemetry/realtime_telemetry.dart';
import 'package:module_realtime/transport/mock_ws_transport.dart';
import 'package:module_realtime/transport/websocket_transport.dart';
import 'package:module_realtime/transport/ws_transport.dart';
import 'package:module_utils/module_utils.dart';
import 'package:uuid/uuid.dart';

/// =============================================================================
/// AppRealtimeClientImpl — Realtime 核心客户端
///
/// 【连接全流程】
///   connect → HTTP 换票 → WS connect → auth → auth_ok → sync → sub → 心跳
///
/// 【收消息】_onEnvelope 按 type 分发
/// 【发消息】sendEvent → WS type:event；服务端 push → type:event 下行
///
/// 初学者请配合阅读：docs/realtime-beginner-walkthrough.md（Go 仓库）
/// =============================================================================
class AppRealtimeClientImpl implements AppRealtimeClient {
  AppRealtimeClientImpl({
    required WsTicketApi ticketApi,
    required WsSyncApi syncApi,
    required OutboundQueueManager outboundQueue,
    required RealtimeSeqStore seqStore,
    required InboundRouter router,
    required GlobalNotifyHandler notifyHandler,
    required RealtimeTelemetry telemetry,
    WsTransport? transport,
  })  : _ticketApi = ticketApi,
        _syncApi = syncApi,
        _outboundQueue = outboundQueue,
        _seqStore = seqStore,
        _router = router,
        _notifyHandler = notifyHandler,
        _telemetry = telemetry,
        _transport = transport ??
            (RealtimeConfig.useMockGateway
                ? MockWsTransport()
                : WebSocketTransport());

  final WsTicketApi _ticketApi;
  final WsSyncApi _syncApi;
  final OutboundQueueManager _outboundQueue;
  final RealtimeSeqStore _seqStore;
  final InboundRouter _router;
  final GlobalNotifyHandler _notifyHandler;
  final RealtimeTelemetry _telemetry;
  final WsTransport _transport;

  final _uuid = const Uuid();
  final _stateController = StreamController<RealtimeConnectionState>.broadcast();
  final _reconnectPolicy = ReconnectPolicy();
  final _subscribedTopics = <String>{};
  final _pendingAcks = <String, Timer>{};

  HeartbeatScheduler? _heartbeat;
  StreamSubscription<RealtimeEnvelope>? _inboundSub;
  StreamSubscription<List<ConnectivityResult>>? _networkSub;
  Timer? _reconnectTimer;

  RealtimeConnectionState _state = RealtimeConnectionState.disconnected;
  int _reconnectCount = 0;
  bool _keepAliveInBackground = false;
  bool _manualDisconnect = false;
  bool _initialized = false;

  @override
  Stream<RealtimeConnectionState> get connectionState => _stateController.stream;

  @override
  RealtimeConnectionState get currentState => _state;

  @override
  int get lastSeq => _seqStore.lastSeq;

  @override
  int get reconnectCount => _reconnectCount;

  @override
  int get outboundQueueDepth => _outboundQueue.depth;

  @override
  bool get keepAliveInBackground => _keepAliveInBackground;

  Future<void> prepare() async {
    if (_initialized) return;
    await _seqStore.load();
    await _outboundQueue.refreshDepth();
    _initialized = true;
  }

  @override
  Future<void> connect() async {
    if (!AuthSession.isLoggedIn) {
      LogUtils.i('[Realtime] skip connect: not logged in');
      return;
    }
    // 防止重复 connect 造成多条 WS
    if (_state == RealtimeConnectionState.connected ||
        _state == RealtimeConnectionState.connecting ||
        _state == RealtimeConnectionState.authenticating) {
      LogUtils.i('[Realtime] skip connect: already ${_state.label}');
      return;
    }

    _manualDisconnect = false;
    await _connectInternal(isReconnect: false);
  }

  /// 内部连接：换票 → 建连 → 发 auth 帧。
  Future<void> _connectInternal({required bool isReconnect}) async {
    _reconnectTimer?.cancel();
    _setState(
      isReconnect
          ? RealtimeConnectionState.reconnecting
          : RealtimeConnectionState.connecting,
    );

    final sw = Stopwatch()..start();
    try {
      final token = _resolveAccessToken();
      final ticket = await _ticketApi.fetchTicket(accessToken: token);
      final uri = Uri.parse(BackendWsConfig.resolveWsUrl(ticket.wsUrl));

      await _transport.connect(uri);
      _listenInbound();

      _setState(RealtimeConnectionState.authenticating);
      await _transport.send(
        RealtimeEnvelope(
          id: _uuid.v4(),
          type: 'auth',
          ts: DateTime.now().millisecondsSinceEpoch,
          payload: {
            'ticket': ticket.ticket,
            'platform': 'mobile',
            'connId': ticket.connId,
          },
        ),
      );

      _telemetry.trace(
        'ws_connect',
        durationMs: sw.elapsedMilliseconds,
        params: {'mock': RealtimeConfig.useMockGateway},
      );
    } catch (e, st) {
      sw.stop();
      _telemetry.error('ws_connect_fail', e);
      if (SessionGuardHook.isForceLogoutError(e)) {
        final recovered = await SessionRecovery.tryRecover();
        if (recovered) {
          LogUtils.i('[Realtime] session recovered on same device, retry connect');
          await _connectInternal(isReconnect: isReconnect);
          return;
        }
        _manualDisconnect = true;
        _reconnectTimer?.cancel();
        _setState(RealtimeConnectionState.disconnected);
        LogUtils.w('[Realtime] session invalid, stop reconnect');
        unawaited(SessionGuardHook.handleIfForceLogout(e));
        return;
      }
      LogUtils.e('[Realtime] connect failed', e, st);
      _scheduleReconnect(reason: e.toString());
    }
  }

  void _listenInbound() {
    _inboundSub?.cancel();
    _inboundSub = _transport.inbound.listen(
      _onEnvelope,
      onError: (e, st) {
        LogUtils.w('[Realtime] inbound error', e, st);
        _handleTransportLost(reason: e.toString());
      },
      onDone: () => _handleTransportLost(reason: 'stream_done'),
    );
  }

  Future<void> _onEnvelope(RealtimeEnvelope envelope) async {
    switch (envelope.type) {
      case 'auth_ok':
        // 鉴权成功：重置重连计数，启动心跳，sync 补消息，重新 sub
        _reconnectPolicy.reset();
        _reconnectCount = 0;
        _setState(RealtimeConnectionState.connected);
        LogUtils.i(
          '[Realtime] auth_ok topics=${_subscribedTopics.join(',')} lastSeq=${_seqStore.lastSeq}',
        );
        _startHeartbeat();
        await _afterConnected();
      case 'pong':
        _heartbeat?.onPong(envelope.id ?? '');
      case 'ack':
        // 服务端确认收到客户端 event（如 presence.report）
        final refId = envelope.payload['refId']?.toString();
        if (refId != null) _completeAck(refId);
      case 'error':
        final code = envelope.payload['code'];
        LogUtils.w('[Realtime] server error $code ${envelope.payload}');
        _telemetry.error('ws_server_error', Exception('$code'));
      case 'event':
        // seq 去重后路由；sys.notify 仍交给 Handler（notifyId 去重，避免 seq 已更新但 Banner 未展示）
        final seqAccepted = _seqStore.acceptSeq(envelope.seq);
        if (seqAccepted) {
          _router.dispatch(envelope);
        }
        if (envelope.topic == RealtimeTopics.sysNotify) {
          await _notifyHandler.handle(envelope);
        }
      default:
        break;
    }
  }

  /// auth_ok 之后：HTTP sync 补离线消息 → 重发出站队列 → 重新订阅 topic。
  Future<void> _afterConnected() async {
    final syncSw = Stopwatch()..start();
    try {
      final sync = await _syncApi.sync(
        sinceSeq: _seqStore.lastSeq,
        topics: _subscribedTopics.toList(),
      );
      for (final event in sync.events) {
        final seqAccepted = _seqStore.acceptSeq(event.seq);
        if (seqAccepted) {
          _router.dispatch(event);
        }
        if (event.topic == RealtimeTopics.sysNotify) {
          await _notifyHandler.handle(event);
        }
      }
      _seqStore.setLastSeq(sync.latestSeq);
      _telemetry.trace('ws_sync', durationMs: syncSw.elapsedMilliseconds);
    } catch (e, st) {
      _telemetry.error('ws_sync_fail', e);
      LogUtils.w('[Realtime] sync failed', e, st);
    }

    await _replayOutboundQueue();

    if (_subscribedTopics.isNotEmpty) {
      await _sendSubscribe(_subscribedTopics.toList());
    }

    _ensureNetworkWatcher();
  }

  Future<void> _replayOutboundQueue() async {
    final items = await _outboundQueue.pendingItems();
    for (final item in items) {
      await _sendOutbound(
        messageId: item.messageId,
        topic: item.topic,
        eventName: item.eventName,
        payload: item.decodePayload(),
      );
    }
  }

  void _startHeartbeat() {
    _heartbeat?.stop();
    _heartbeat = HeartbeatScheduler(
      onSendPing: (pingId) async {
        await _transport.send(
          RealtimeEnvelope(
            id: pingId,
            type: 'ping',
            ts: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      },
      onTimeout: () => _handleTransportLost(reason: 'heartbeat_timeout'),
    )..start();
  }

  void _handleTransportLost({required String reason}) {
    if (_manualDisconnect) return;
    _heartbeat?.stop();
    _telemetry.metric('ws_transport_lost', params: {'reason': reason});
    unawaited(_transport.close());
    _scheduleReconnect(reason: reason);
  }

  void _scheduleReconnect({required String reason}) {
    if (_manualDisconnect) return;
    _reconnectCount++;
    _setState(RealtimeConnectionState.reconnecting);
    final delay = _reconnectPolicy.nextDelay();
    _telemetry.metric(
      'ws_reconnect_scheduled',
      params: {'reason': reason, 'delayMs': delay.inMilliseconds, 'attempt': _reconnectCount},
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      unawaited(_connectInternal(isReconnect: true));
    });
  }

  void _ensureNetworkWatcher() {
    _networkSub ??= Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && !_manualDisconnect && !currentState.isActive) {
        unawaited(connect());
      }
    });
  }

  @override
  Future<void> disconnect({String? reason, bool clearQueue = false}) async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _heartbeat?.stop();
    await _inboundSub?.cancel();
    _inboundSub = null;
    await _transport.close(code: 1000, reason: reason);
    if (clearQueue) await _outboundQueue.clear();
    _setState(RealtimeConnectionState.disconnected);
    LogUtils.i('[Realtime] disconnected reason=$reason');
  }

  @override
  Future<void> subscribeTopics(List<String> topics) async {
    _subscribedTopics.addAll(topics);
    if (currentState.isActive) {
      await _sendSubscribe(topics);
    }
  }

  @override
  Future<void> unsubscribeTopics(List<String> topics) async {
    for (final t in topics) {
      _subscribedTopics.remove(t);
    }
    if (currentState.isActive) {
      await _transport.send(
        RealtimeEnvelope(
          id: _uuid.v4(),
          type: 'unsub',
          ts: DateTime.now().millisecondsSinceEpoch,
          payload: {'topics': topics},
        ),
      );
    }
  }

  Future<void> _sendSubscribe(List<String> topics) async {
    await _transport.send(
      RealtimeEnvelope(
        id: _uuid.v4(),
        type: 'sub',
        ts: DateTime.now().millisecondsSinceEpoch,
        payload: {'topics': topics},
      ),
    );
  }

  @override
  Stream<RealtimeEnvelope> watchTopic(String topic) => _router.watchTopic(topic);

  @override
  Stream<RealtimeEnvelope> watchEvents({String? eventName}) =>
      _router.watchEvents(eventName: eventName);

  @override
  Future<void> sendEvent({
    required String topic,
    required String eventName,
    Map<String, dynamic>? payload,
    bool requireAck = true,
  }) async {
    // 先入 SQLite 队列：断线期间消息不丢，连上后 _replayOutboundQueue 重发
    final messageId = await _outboundQueue.enqueue(
      topic: topic,
      eventName: eventName,
      payload: payload,
    );
    if (!currentState.isActive) {
      _setState(RealtimeConnectionState.degraded);
      return;
    }
    await _sendOutbound(
      messageId: messageId,
      topic: topic,
      eventName: eventName,
      payload: payload ?? {},
      requireAck: requireAck,
    );
  }

  /// 构造 type=event 的 RealtimeEnvelope 并通过 WS 发送。
  Future<void> _sendOutbound({
    required String messageId,
    required String topic,
    required String eventName,
    required Map<String, dynamic> payload,
    bool requireAck = true,
  }) async {
    await _outboundQueue.markSent(messageId);
    final sw = Stopwatch()..start();
    await _transport.send(
      RealtimeEnvelope(
        id: messageId,
        type: 'event',
        topic: topic,
        ts: DateTime.now().millisecondsSinceEpoch,
        payload: {
          'name': eventName,
          ...payload,
        },
      ),
    );

    if (requireAck) {
      _pendingAcks[messageId]?.cancel();
      _pendingAcks[messageId] = Timer(RealtimeConfig.outboundAckTimeout, () async {
        _telemetry.metric('ws_outbound_ack_timeout', params: {'messageId': messageId});
        await _outboundQueue.markFailed(messageId);
      });
    } else {
      await _outboundQueue.markAcked(messageId);
    }

    _telemetry.trace('ws_send', durationMs: sw.elapsedMilliseconds, params: {
      'topic': topic,
      'eventName': eventName,
    });
  }

  void _completeAck(String refId) {
    _pendingAcks.remove(refId)?.cancel();
    unawaited(_outboundQueue.markAcked(refId));
  }

  @override
  void setKeepAliveInBackground(bool enabled) {
    _keepAliveInBackground = enabled;
    LogUtils.i('[Realtime] keepAliveInBackground=$enabled');
  }

  void onAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_manualDisconnect && !currentState.isActive) {
        unawaited(connect());
      }
      return;
    }
    if (state == AppLifecycleState.paused && !_keepAliveInBackground) {
      if (currentState.isActive) {
        unawaited(disconnect(reason: 'app_paused'));
      }
    }
  }

  void _setState(RealtimeConnectionState state) {
    if (_state == state) return;
    final previous = _state;
    _state = state;
    _stateController.add(state);
    LogUtils.i('[Realtime] state ${previous.name} -> ${state.name} (${state.label})');
    _telemetry.metric('ws_state', params: {'state': state.name});
  }

  String _resolveAccessToken() {
    if (!Get.isRegistered<UserService>()) {
      throw StateError('UserService 未注册，无法连接 Realtime');
    }
    final token = Get.find<UserService>().currentUser.value?.token;
    if (token == null || token.isEmpty) {
      throw StateError('未登录或 token 为空，无法连接 Realtime');
    }
    return token;
  }

  Future<void> dispose() async {
    await disconnect(reason: 'dispose', clearQueue: false);
    await _networkSub?.cancel();
    _router.dispose();
    _transport.dispose();
    await _stateController.close();
  }
}
