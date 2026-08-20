import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wys_push/wys_push.dart';

void main() {
  test('queues events until ready and dispatches them in order', () async {
    final controller = StreamController<PushEvent>();
    final dispatcher = PushEventDispatcher();
    final calls = <String>[];
    dispatcher.init(
      events: controller.stream,
      onNotificationArrived: (_) => calls.add('arrived'),
      onNotificationOpened: (_) => calls.add('opened'),
      onCustomMessage: (_) => calls.add('custom'),
    );

    controller
      ..add(const PushEvent(type: PushEventType.notificationArrived))
      ..add(const PushEvent(type: PushEventType.notificationOpened));
    await Future<void>.delayed(Duration.zero);

    expect(calls, isEmpty);
    expect(dispatcher.pendingEventCount, 2);

    dispatcher.markAppReady();
    expect(calls, <String>['arrived', 'opened']);
    expect(dispatcher.pendingEventCount, 0);

    controller.add(const PushEvent(type: PushEventType.customMessage));
    await Future<void>.delayed(Duration.zero);
    expect(calls, <String>['arrived', 'opened', 'custom']);

    dispatcher.dispose();
    await controller.close();
  });
}
