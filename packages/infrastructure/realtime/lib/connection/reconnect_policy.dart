import 'dart:math';

import 'package:module_realtime/config/realtime_config.dart';

/// 指数退避 + jitter。
class ReconnectPolicy {
  ReconnectPolicy({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _attempt = 0;

  int get attempt => _attempt;

  void reset() => _attempt = 0;

  Duration nextDelay() {
    _attempt++;
    final baseMs = RealtimeConfig.reconnectInitial.inMilliseconds *
        pow(RealtimeConfig.reconnectMultiplier, _attempt - 1).toInt();
    final capped = min(baseMs, RealtimeConfig.reconnectMax.inMilliseconds);
    final jitter = (capped * RealtimeConfig.reconnectJitterRatio).toInt();
    final delta = jitter == 0 ? 0 : _random.nextInt(jitter * 2) - jitter;
    return Duration(milliseconds: max(500, capped + delta));
  }
}
