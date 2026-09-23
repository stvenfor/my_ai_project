import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:wys_push/wys_push.dart';

/// 极光推送真实实现，基于 `jpush_flutter`（iOS / Android / HarmonyOS）。
///
/// 在应用启动时注入：`PushManager.instance = JPushManager()`；
/// 隐私同意后再 [reInit]/[init]，避免权限弹窗盖住隐私协议。
///
/// Android 13+ `POST_NOTIFICATIONS` 由 `module_linking` 的 `JPushPushService` 申请。
class JPushManager extends PushManager {
  JPushManager({JPushFlutterInterface? jpush}) : super.protected() {
    _jpush = jpush ?? JPush.newJPush();
    _eventController = StreamController<PushEvent>.broadcast(
      onListen: _flushPendingEvents,
    );
  }

  /// 6002（超时）/ 6014（服务忙）时的重试间隔，对齐极光官方建议。
  static const List<Duration> _aliasRetryDelays = <Duration>[
    Duration(seconds: 5),
    Duration(seconds: 15),
    Duration(seconds: 60),
  ];

  late final JPushFlutterInterface _jpush;

  bool _initialized = false;
  bool _callbackRegistered = false;
  bool _aliasInFlight = false;
  String? _activeAppKey;
  late final StreamController<PushEvent> _eventController;
  final List<PushEvent> _pendingEvents = <PushEvent>[];

  @override
  bool get isInitialized => _initialized;

  @override
  Stream<PushEvent> get onEvent => _eventController.stream;

  @override
  void init({bool isFirstUse = false}) {
    _registerCallbackOnce();
    // HarmonyOS 插件未实现 setAuth。首次安装必须等用户同意隐私协议后，
    // 再通过 reInit 执行 setup，避免通知权限弹窗覆盖隐私协议弹窗。
    if (isFirstUse) {
      debugPrint('[JPush] first use, wait for privacy agreement');
      return;
    }
    _setupForCurrentEnvironment();
  }

  void _registerCallbackOnce() {
    if (_callbackRegistered) return;

    if (!kIsWeb && Platform.operatingSystem == 'ohos') {
      _jpush.setCallBackHarmony((eventName, data) {
        debugPrint('[JPush] event: $eventName, data: $data');
        _handleEvent(eventName, data);
      });
    } else if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // 参数集对齐当前 CPF jpush_flutter（无 onNotifyButtonClick / onVoipMessage）。
      _jpush.addEventHandler(
        onReceiveNotification: (data) =>
            _handlePlatformEvent('onReceiveNotification', data),
        onOpenNotification: (data) =>
            _handlePlatformEvent('onOpenNotification', data),
        onReceiveMessage: (data) =>
            _handlePlatformEvent('onReceiveMessage', data),
        onReceiveNotificationAuthorization: (data) =>
            _handlePlatformEvent('onReceiveNotificationAuthorization', data),
        onNotifyMessageUnShow: (data) =>
            _handlePlatformEvent('onNotifyMessageUnShow', data),
        onConnected: (data) => _handlePlatformEvent('onConnected', data),
        onInAppMessageClick: (data) =>
            _handlePlatformEvent('onInAppMessageClick', data),
        onInAppMessageShow: (data) =>
            _handlePlatformEvent('onInAppMessageShow', data),
        onCommandResult: (data) => _handlePlatformEvent('onCommandResult', data),
        onReceiveDeviceToken: (data) =>
            _handlePlatformEvent('onReceiveDeviceToken', data),
      );
    }
    _callbackRegistered = true;
  }

  Future<void> _handlePlatformEvent(
    String eventName,
    Map<String, dynamic> data,
  ) async {
    debugPrint('[JPush] event: $eventName, data: $data');
    _handleEvent(eventName, data);
  }

  void _setupForCurrentEnvironment() {
    if (!PushConfig.isConfigured) {
      debugPrint(
        '[JPush] AppKey not configured (placeholder), skip setup',
      );
      return;
    }

    final appKey = PushConfig.appKey;
    if (_initialized && _activeAppKey == appKey) {
      debugPrint('[JPush] environment unchanged, skip setup, appKey: $appKey');
      return;
    }

    _jpush.setup(
      appKey: appKey,
      channel: !kIsWeb && Platform.isIOS
          ? PushConfig.iosChannel
          : PushConfig.defaultChannel,
      production: PushConfig.isProduction,
      debug: kDebugMode,
    );

    if (!kIsWeb && Platform.isIOS) {
      _jpush.applyPushAuthority(
        const NotificationSettingsIOS(sound: true, alert: true, badge: true),
      );
    }

    _activeAppKey = appKey;
    _initialized = true;
    debugPrint(
      '[JPush] initialized, environment: '
      '${PushConfig.isProduction ? 'product' : 'test'}, appKey: $appKey',
    );
  }

  @override
  void reInit() {
    _registerCallbackOnce();
    _setupForCurrentEnvironment();
  }

  void _handleEvent(String eventName, dynamic data) {
    final event = PushPayloadParser.parse(eventName, data);
    if (event == null) return;
    if (_eventController.hasListener) {
      _eventController.add(event);
    } else {
      _pendingEvents.add(event);
    }
  }

  void _flushPendingEvents() {
    if (_pendingEvents.isEmpty) return;
    final events = List<PushEvent>.of(_pendingEvents);
    _pendingEvents.clear();
    for (final event in events) {
      _eventController.add(event);
    }
  }

  @override
  Future<bool> setAlias(String alias) async {
    if (alias.isEmpty) {
      debugPrint('[JPush] setAlias skipped: empty alias');
      return false;
    }
    if (!_initialized) {
      debugPrint('[JPush] setAlias skipped: not initialized');
      return false;
    }
    if (_aliasInFlight) {
      debugPrint('[JPush] setAlias skipped: already in flight');
      return false;
    }

    _aliasInFlight = true;
    try {
      final ready = await _waitForRegistrationId();
      if (!ready) {
        debugPrint(
          '[JPush] registrationID not ready yet, still try setAlias',
        );
      }

      var attempt = 0;
      while (true) {
        attempt++;
        try {
          final result = await _jpush.setAlias(alias);
          debugPrint('[JPush] setAlias result: $result (attempt=$attempt)');
          return true;
        } catch (e) {
          final retryable = _isRetryableAliasError(e);
          final delayIndex = attempt - 1;
          if (!retryable || delayIndex >= _aliasRetryDelays.length) {
            debugPrint('[JPush] setAlias error: $e (attempt=$attempt)');
            return false;
          }
          final delay = _aliasRetryDelays[delayIndex];
          debugPrint(
            '[JPush] setAlias retryable error: $e, '
            'retry in ${delay.inSeconds}s (attempt=$attempt)',
          );
          await Future<void>.delayed(delay);
        }
      }
    } finally {
      _aliasInFlight = false;
    }
  }

  Future<bool> _waitForRegistrationId({
    Duration timeout = const Duration(seconds: 8),
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        final id = await _jpush.getRegistrationID();
        if (id.isNotEmpty) {
          debugPrint('[JPush] registrationID ready: $id');
          return true;
        }
      } catch (_) {}
      await Future<void>.delayed(interval);
    }
    return false;
  }

  static bool _isRetryableAliasError(Object error) {
    if (error is PlatformException) {
      return error.code == '6002' || error.code == '6014';
    }
    final text = error.toString();
    return text.contains('6002') || text.contains('6014');
  }

  @override
  Future<void> deleteAlias() async {
    if (!_initialized) return;
    try {
      final result = await _jpush.deleteAlias();
      debugPrint('[JPush] deleteAlias result: $result');
    } catch (e) {
      debugPrint('[JPush] deleteAlias error: $e');
    }
  }

  @override
  Future<void> setBadgeNum(int num) async {
    if (!_initialized) return;
    try {
      await _jpush.setBadge(num);
      debugPrint('[JPush] setBadge: $num');
    } catch (e) {
      debugPrint('[JPush] setBadge error: $e');
    }
  }

  @override
  Future<String?> getRegistrationID() async {
    if (!_initialized) return null;
    try {
      final id = await _jpush.getRegistrationID();
      debugPrint('[JPush] registrationID: $id');
      return id;
    } catch (e) {
      debugPrint('[JPush] getRegistrationID error: $e');
      return null;
    }
  }

  @override
  Future<bool> sendTestNotification() async {
    if (!_initialized) return false;
    try {
      await _jpush.sendLocalNotification(
        LocalNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: '测试推送',
          content: '这是一条来自调试工具的测试推送消息',
          fireTime: DateTime.now(),
          buildId: 1,
          extra: {'test': 'true'},
        ),
      );
      debugPrint('[JPush] sendLocalNotification success');
      return true;
    } catch (e) {
      debugPrint('[JPush] sendLocalNotification error: $e');
      return false;
    }
  }
}
