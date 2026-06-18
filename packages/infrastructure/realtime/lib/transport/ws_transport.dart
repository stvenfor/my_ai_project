import 'dart:async';

import 'package:module_core/model/realtime/realtime_envelope.dart';

abstract class WsTransport {
  Stream<RealtimeEnvelope> get inbound;

  bool get isConnected;

  Future<void> connect(Uri uri);

  Future<void> send(RealtimeEnvelope envelope);

  Future<void> close({int? code, String? reason});

  void dispose();
}
