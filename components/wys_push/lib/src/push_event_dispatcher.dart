import 'dart:async';

import 'push_event.dart';
import 'push_manager.dart';

typedef PushNotificationCallback =
    void Function(PushNotification? notification);
typedef PushCustomMessageCallback = void Function(PushCustomMessage? message);

/// 通用推送事件调度器：订阅、就绪前缓存、缓存释放和分类回调。
class PushEventDispatcher {
  PushEventDispatcher();

  static final PushEventDispatcher instance = PushEventDispatcher();

  StreamSubscription<PushEvent>? _subscription;
  final List<PushEvent> _pendingEvents = <PushEvent>[];
  bool _appReady = false;

  PushNotificationCallback? _onNotificationArrived;
  PushNotificationCallback? _onNotificationOpened;
  PushCustomMessageCallback? _onCustomMessage;

  bool get isAppReady => _appReady;
  int get pendingEventCount => _pendingEvents.length;

  void init({
    Stream<PushEvent>? events,
    PushNotificationCallback? onNotificationArrived,
    PushNotificationCallback? onNotificationOpened,
    PushCustomMessageCallback? onCustomMessage,
  }) {
    _onNotificationArrived = onNotificationArrived;
    _onNotificationOpened = onNotificationOpened;
    _onCustomMessage = onCustomMessage;
    _subscription?.cancel();
    _subscription = (events ?? PushManager.instance.onEvent).listen(
      _handleEvent,
    );
  }

  void _handleEvent(PushEvent event) {
    if (!_appReady) {
      _pendingEvents.add(event);
      return;
    }
    _dispatch(event);
  }

  void _dispatch(PushEvent event) {
    switch (event.type) {
      case PushEventType.notificationArrived:
        _onNotificationArrived?.call(event.notification);
      case PushEventType.notificationOpened:
        _onNotificationOpened?.call(event.notification);
      case PushEventType.customMessage:
        _onCustomMessage?.call(event.message);
    }
  }

  /// 应用业务和路由就绪后，按接收顺序释放缓存事件。
  void markAppReady() {
    if (_appReady) return;
    _appReady = true;
    final events = List<PushEvent>.of(_pendingEvents);
    _pendingEvents.clear();
    for (final event in events) {
      _dispatch(event);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _pendingEvents.clear();
    _appReady = false;
  }
}
