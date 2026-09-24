import 'dart:async';

import 'package:module_core/env/app_env.dart';
import 'package:module_core/service/environment_service.dart';
import 'package:module_rongcloud_im/api/im_session_api.dart';
import 'package:module_rongcloud_im/config/rong_im_config.dart';
import 'package:module_utils/module_utils.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

/// 融云 Engine 持有（Mock / Real）+ 会话/消息薄封装。
class RongEngineHolder {
  RongEngineHolder({EnvironmentService? envService}) : _envService = envService;

  final EnvironmentService? _envService;
  bool _connected = false;
  ImSessionResult? _session;
  RCIMIWEngine? _engine;
  bool _listenerAttached = false;

  bool get isConnected => _connected;

  ImSessionResult? get session => _session;

  RCIMIWEngine? get engine => _engine;

  bool get isMock => RongImConfig.useMockImFor(_envService?.rongAppKey);

  /// 真实模式且 Engine 已创建。
  bool get isSdkReady => !isMock && _engine != null && _connected;

  Future<void> connectMock({required ImSessionResult session}) async {
    _session = session;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _connected = true;
    final appKey = _envService?.rongAppKey ?? 'DEV_RONG_APP_KEY_PLACEHOLDER';
    LogUtils.i('[RongEngine] mock connected appKey=$appKey imUserId=${session.imUserId}');
  }

  Future<void> connectReal({required ImSessionResult session}) async {
    if (isMock) {
      return connectMock(session: session);
    }
    final appKey = (_envService?.rongAppKey ?? '').trim();
    if (appKey.isEmpty || appKey.toUpperCase().contains('PLACEHOLDER')) {
      throw StateError('融云 App Key 未配置');
    }
    _session = session;
    final options = RCIMIWEngineOptions.create();
    _engine = await RCIMIWEngine.create(appKey, options);
    final completer = Completer<void>();
    final code = await _engine!.connect(
      session.token,
      RongImConfig.connectTimeoutSeconds,
      callback: RCIMIWConnectCallback(
        onDatabaseOpened: (int? c) {},
        onConnected: (int? c, String? userId) {
          if (completer.isCompleted) return;
          if (c == 0) {
            completer.complete();
          } else {
            completer.completeError(StateError('融云连接失败 code=$c'));
          }
        },
      ),
    );
    if (code != 0 && !completer.isCompleted) {
      completer.completeError(StateError('融云 connect 返回 code=$code'));
    }
    await completer.future.timeout(
      const Duration(seconds: RongImConfig.connectTimeoutSeconds + 5),
    );
    _connected = true;
    LogUtils.i('[RongEngine] real connected appKey=$appKey imUserId=${session.imUserId}');
  }

  void attachMessageListener(
    void Function(RCIMIWMessage message) onMessage,
  ) {
    final engine = _engine;
    if (engine == null || _listenerAttached) return;
    _listenerAttached = true;
    engine.onMessageReceived = (message, left, offline, hasPackage) {
      if (message != null) onMessage(message);
    };
  }

  Future<List<RCIMIWConversation>> fetchConversations({int count = 50}) async {
    final engine = _engine;
    if (engine == null) return const [];
    final completer = Completer<List<RCIMIWConversation>>();
    final code = await engine.getConversations(
      [RCIMIWConversationType.private, RCIMIWConversationType.group],
      null,
      0,
      count,
      callback: IRCIMIWGetConversationsCallback(
        onSuccess: (list) {
          if (!completer.isCompleted) {
            completer.complete(list ?? const []);
          }
        },
        onError: (c) {
          if (!completer.isCompleted) {
            completer.completeError(StateError('getConversations code=$c'));
          }
        },
      ),
    );
    if (code != 0 && !completer.isCompleted) {
      completer.completeError(StateError('getConversations 返回 code=$code'));
    }
    return completer.future.timeout(const Duration(seconds: 8));
  }

  Future<List<RCIMIWMessage>> fetchMessages({
    required RCIMIWConversationType type,
    required String targetId,
    int sentTime = 0,
    int count = 20,
  }) async {
    final engine = _engine;
    if (engine == null) return const [];
    final completer = Completer<List<RCIMIWMessage>>();
    final code = await engine.getMessages(
      type,
      targetId,
      null,
      sentTime,
      RCIMIWTimeOrder.before,
      RCIMIWMessageOperationPolicy.local,
      count,
      callback: IRCIMIWGetMessagesCallback(
        onSuccess: (list, syncTimestamp, hasMoreMsg) {
          if (!completer.isCompleted) {
            completer.complete(list ?? const []);
          }
        },
        onError: (c) {
          if (!completer.isCompleted) {
            completer.completeError(StateError('getMessages code=$c'));
          }
        },
      ),
    );
    if (code != 0 && !completer.isCompleted) {
      completer.completeError(StateError('getMessages 返回 code=$code'));
    }
    return completer.future.timeout(const Duration(seconds: 8));
  }

  Future<RCIMIWMessage> sendText({
    required RCIMIWConversationType type,
    required String targetId,
    required String text,
  }) async {
    final engine = _requireEngine();
    final msg = await engine.createTextMessage(type, targetId, null, text);
    if (msg == null) throw StateError('createTextMessage failed');
    return _sendPlain(msg);
  }

  Future<RCIMIWMessage> sendImage({
    required RCIMIWConversationType type,
    required String targetId,
    required String localPath,
  }) async {
    final engine = _requireEngine();
    final msg = await engine.createImageMessage(type, targetId, null, localPath);
    if (msg == null) throw StateError('createImageMessage failed');
    return _sendMedia(msg);
  }

  Future<RCIMIWMessage> sendVoice({
    required RCIMIWConversationType type,
    required String targetId,
    required String localPath,
    required int durationSeconds,
  }) async {
    final engine = _requireEngine();
    final msg = await engine.createVoiceMessage(
      type,
      targetId,
      null,
      localPath,
      durationSeconds,
    );
    if (msg == null) throw StateError('createVoiceMessage failed');
    return _sendMedia(msg);
  }

  Future<RCIMIWMessage> _sendPlain(RCIMIWMessage message) async {
    final engine = _requireEngine();
    final completer = Completer<RCIMIWMessage>();
    final code = await engine.sendMessage(
      message,
      callback: RCIMIWSendMessageCallback(
        onMessageSent: (c, sent) {
          if (completer.isCompleted) return;
          if (c == 0 && sent != null) {
            completer.complete(sent);
          } else {
            completer.completeError(StateError('sendMessage code=$c'));
          }
        },
      ),
    );
    if (code != 0 && !completer.isCompleted) {
      completer.completeError(StateError('sendMessage 返回 code=$code'));
    }
    return completer.future.timeout(const Duration(seconds: 15));
  }

  Future<RCIMIWMessage> _sendMedia(RCIMIWMediaMessage message) async {
    final engine = _requireEngine();
    final completer = Completer<RCIMIWMessage>();
    final code = await engine.sendMediaMessage(
      message,
      listener: RCIMIWSendMediaMessageListener(
        onMediaMessageSent: (c, sent) {
          if (completer.isCompleted) return;
          if (c == 0 && sent != null) {
            completer.complete(sent);
          } else {
            completer.completeError(StateError('sendMediaMessage code=$c'));
          }
        },
      ),
    );
    if (code != 0 && !completer.isCompleted) {
      completer.completeError(StateError('sendMediaMessage 返回 code=$code'));
    }
    return completer.future.timeout(const Duration(seconds: 60));
  }

  RCIMIWEngine _requireEngine() {
    final engine = _engine;
    if (engine == null || !_connected) {
      throw StateError('融云 Engine 未就绪');
    }
    return engine;
  }

  Future<void> disconnect({String? reason}) async {
    final engine = _engine;
    _engine = null;
    _connected = false;
    _session = null;
    _listenerAttached = false;
    if (engine != null) {
      try {
        await engine.disconnect(false);
      } catch (e, st) {
        LogUtils.e('[RongEngine] disconnect error', e, st);
      }
    }
    LogUtils.i(
      '[RongEngine] disconnected reason=$reason env=${_envService?.currentEnv.value ?? AppEnv.test}',
    );
  }
}
