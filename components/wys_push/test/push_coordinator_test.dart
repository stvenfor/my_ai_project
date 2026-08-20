import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wys_push/wys_push.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.tf.flutter/deeplink.test');
  late WysPushCoordinator coordinator;

  tearDown(() async {
    coordinator.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('caches initial link and routes it after app is ready', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return call.method == 'getInitialLink'
              ? 'tfapp://tf.com/homeMall'
              : null;
        });
    final routes = <String>[];
    coordinator = WysPushCoordinator(
      deepLinkChannel: channel,
      routeScheduler: (action) => action(),
    );

    coordinator.init(
      events: const Stream<PushEvent>.empty(),
      onRoute: routes.add,
    );
    await tester.pump();

    expect(routes, isEmpty);
    expect(coordinator.pendingRouteCount, 1);

    coordinator.markAppReady();
    expect(routes, <String>['tfapp://tf.com/homeMall']);
  });

  testWidgets('deduplicates JPush opened event and matching Want route', (
    tester,
  ) async {
    const uri = 'tfapp://tf.com/homePaoPao';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return call.method == 'getInitialLink' ? uri : null;
        });
    final events = StreamController<PushEvent>();
    final routes = <String>[];
    final opened = <PushNotification?>[];
    coordinator = WysPushCoordinator(
      deepLinkChannel: channel,
      routeScheduler: (action) => action(),
    );
    coordinator.init(
      events: events.stream,
      onRoute: routes.add,
      onNotificationOpened: opened.add,
    );

    events.add(
      const PushEvent(
        type: PushEventType.notificationOpened,
        notification: PushNotification(deeplink: uri),
      ),
    );
    await tester.pump();
    coordinator.markAppReady();
    expect(opened, hasLength(1));
    expect(routes, <String>[uri]);
    await events.close();
  });

  testWidgets('dispatches business callbacks and ignores empty links', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    final events = StreamController<PushEvent>();
    final calls = <String>[];
    final routes = <String>[];
    coordinator = WysPushCoordinator(deepLinkChannel: channel);
    coordinator.init(
      events: events.stream,
      onRoute: routes.add,
      onNotificationArrived: (_) => calls.add('arrived'),
      onNotificationOpened: (_) => calls.add('opened'),
      onCustomMessage: (_) => calls.add('custom'),
    );
    coordinator.markAppReady();

    events
      ..add(const PushEvent(type: PushEventType.notificationArrived))
      ..add(const PushEvent(type: PushEventType.notificationOpened))
      ..add(const PushEvent(type: PushEventType.customMessage));
    await tester.pump();
    await tester.pump();

    expect(calls, <String>['arrived', 'opened', 'custom']);
    expect(routes, isEmpty);
    await events.close();
  });

  testWidgets('reinitializing replaces the event subscription', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => null);
    final oldEvents = StreamController<PushEvent>.broadcast();
    final newEvents = StreamController<PushEvent>.broadcast();
    final calls = <String>[];
    coordinator = WysPushCoordinator(deepLinkChannel: channel);
    coordinator.init(
      events: oldEvents.stream,
      onRoute: (_) {},
      onNotificationArrived: (_) => calls.add('old'),
    );
    coordinator.init(
      events: newEvents.stream,
      onRoute: (_) {},
      onNotificationArrived: (_) => calls.add('new'),
    );
    coordinator.markAppReady();

    oldEvents.add(const PushEvent(type: PushEventType.notificationArrived));
    newEvents.add(const PushEvent(type: PushEventType.notificationArrived));
    await tester.pump();

    expect(calls, <String>['new']);
    await oldEvents.close();
    await newEvents.close();
  });
}
