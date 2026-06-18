import 'package:module_utils/module_utils.dart';

/// Realtime 遥测上报（LogUtils + EventBus）。
class RealtimeTelemetryReporter {
  static void report({
    required String type,
    required String name,
    Map<String, dynamic>? params,
  }) {
    final payload = {
      'type': type,
      'name': name,
      if (params != null) ...params,
    };
    LogUtils.i('[RealtimeTelemetry] $payload');
    EventBusUtils.post(
      CustomEvent<String, Map<String, dynamic>>(
        eventType: 'realtime_$type',
        eventValue: payload,
      ),
    );
  }
}
