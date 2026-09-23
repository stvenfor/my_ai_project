import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'push_event.dart';
import 'push_event_dispatcher.dart';

typedef PushRouteCallback = void Function(String uri);
typedef PushRouteScheduler = void Function(void Function() action);

void _scheduleAfterNavigation(void Function() action) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    SchedulerBinding.instance.addPostFrameCallback((_) => action());
  });
}

/// Coordinates push events, launch deep links, readiness and route dispatch.
///
/// Business behavior is supplied through callbacks so this package does not
/// depend on the application's router or feature modules.
class WysPushCoordinator {
  WysPushCoordinator({
    PushEventDispatcher? dispatcher,
    MethodChannel? deepLinkChannel,
    PushRouteScheduler? routeScheduler,
  }) : _dispatcher = dispatcher ?? PushEventDispatcher(),
       _deepLinkChannel =
           deepLinkChannel ?? const MethodChannel('com.xiaomao.flutter/deeplink'),
       _routeScheduler = routeScheduler ?? _scheduleAfterNavigation;

  static final WysPushCoordinator instance = WysPushCoordinator();

  static const Duration _duplicateRouteWindow = Duration(seconds: 5);

  final PushEventDispatcher _dispatcher;
  final MethodChannel _deepLinkChannel;
  final PushRouteScheduler _routeScheduler;
  final List<String> _pendingRoutes = <String>[];
  final Map<String, DateTime> _recentRoutes = <String, DateTime>{};

  PushRouteCallback? _onRoute;
  PushNotificationCallback? _onNotificationArrived;
  PushNotificationCallback? _onNotificationOpened;
  PushCustomMessageCallback? _onCustomMessage;
  bool _ready = false;
  bool _initialized = false;
  int _generation = 0;

  bool get isInitialized => _initialized;
  bool get isAppReady => _ready;
  int get pendingRouteCount => _pendingRoutes.length;

  /// Starts listening to both JPush events and the host deep-link channel.
  ///
  /// Calling [init] again replaces callbacks and subscriptions without
  /// creating duplicate listeners.
  void init({
    Stream<PushEvent>? events,
    required PushRouteCallback onRoute,
    PushNotificationCallback? onNotificationArrived,
    PushNotificationCallback? onNotificationOpened,
    PushCustomMessageCallback? onCustomMessage,
  }) {
    if (_initialized) {
      _dispatcher.dispose();
    }
    _initialized = true;
    final generation = ++_generation;
    _ready = false;
    _pendingRoutes.clear();
    _recentRoutes.clear();
    _onRoute = onRoute;
    _onNotificationArrived = onNotificationArrived;
    _onNotificationOpened = onNotificationOpened;
    _onCustomMessage = onCustomMessage;

    _dispatcher.init(
      events: events,
      onNotificationArrived: _handleNotificationArrived,
      onNotificationOpened: _handleNotificationOpened,
      onCustomMessage: _handleCustomMessage,
    );
    _deepLinkChannel.setMethodCallHandler(_handleMethodCall);
    unawaited(_loadInitialLink(generation));
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onLink') {
      _acceptRoute(call.arguments?.toString());
    }
    return null;
  }

  Future<void> _loadInitialLink(int generation) async {
    try {
      final uri = await _deepLinkChannel.invokeMethod<String>('getInitialLink');
      if (!_initialized || generation != _generation) return;
      _acceptRoute(uri);
    } on MissingPluginException {
      // The native bridge is intentionally optional on unsupported platforms.
    } on PlatformException {
      // A malformed or unavailable native bridge must not block app startup.
    }
  }

  void _handleNotificationArrived(PushNotification? notification) {
    _onNotificationArrived?.call(notification);
  }

  void _handleNotificationOpened(PushNotification? notification) {
    _onNotificationOpened?.call(notification);
    _acceptRoute(notification?.deeplink);
  }

  void _handleCustomMessage(PushCustomMessage? message) {
    _onCustomMessage?.call(message);
  }

  void _acceptRoute(String? rawUri) {
    final uri = rawUri?.trim();
    if (uri == null || uri.isEmpty || _isDuplicate(uri)) return;

    _recentRoutes[uri] = DateTime.now();
    if (!_ready) {
      if (!_pendingRoutes.contains(uri)) _pendingRoutes.add(uri);
      return;
    }
    _scheduleRoute(uri);
  }

  bool _isDuplicate(String uri) {
    final now = DateTime.now();
    _recentRoutes.removeWhere(
      (_, timestamp) => now.difference(timestamp) > _duplicateRouteWindow,
    );
    final timestamp = _recentRoutes[uri];
    return timestamp != null &&
        now.difference(timestamp) <= _duplicateRouteWindow;
  }

  void _scheduleRoute(String uri) {
    _routeScheduler(() {
      if (_initialized && _ready) _onRoute?.call(uri);
    });
  }

  /// Marks the app router as ready and flushes cached events and links.
  void markAppReady() {
    if (!_initialized) return;
    _ready = true;

    final routes = List<String>.of(_pendingRoutes);
    _pendingRoutes.clear();
    _dispatcher.markAppReady();
    for (final uri in routes) {
      _scheduleRoute(uri);
    }
  }

  /// Cancels subscriptions and resets all coordinator state.
  void dispose() {
    _dispatcher.dispose();
    if (_initialized) {
      _deepLinkChannel.setMethodCallHandler(null);
    }
    _initialized = false;
    _generation++;
    _ready = false;
    _pendingRoutes.clear();
    _recentRoutes.clear();
    _onRoute = null;
    _onNotificationArrived = null;
    _onNotificationOpened = null;
    _onCustomMessage = null;
  }
}
