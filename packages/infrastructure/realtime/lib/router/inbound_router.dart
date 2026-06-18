import 'dart:async';

import 'package:module_core/model/realtime/realtime_envelope.dart';

/// Topic / event 分发。
class InboundRouter {
  final _topicControllers = <String, StreamController<RealtimeEnvelope>>{};
  final _eventController = StreamController<RealtimeEnvelope>.broadcast();

  Stream<RealtimeEnvelope> watchTopic(String topic) {
    return _topicController(topic).stream;
  }

  Stream<RealtimeEnvelope> watchEvents({String? eventName}) {
    if (eventName == null) return _eventController.stream;
    return _eventController.stream.where(
      (e) => e.eventName == eventName,
    );
  }

  void dispatch(RealtimeEnvelope envelope) {
    final topic = envelope.topic;
    if (topic != null && _topicControllers.containsKey(topic)) {
      _topicController(topic).add(envelope);
    }
    if (envelope.type == 'event') {
      _eventController.add(envelope);
    }
  }

  StreamController<RealtimeEnvelope> _topicController(String topic) {
    return _topicControllers.putIfAbsent(
      topic,
      () => StreamController<RealtimeEnvelope>.broadcast(),
    );
  }

  void dispose() {
    for (final c in _topicControllers.values) {
      unawaited(c.close());
    }
    _topicControllers.clear();
    unawaited(_eventController.close());
  }
}
