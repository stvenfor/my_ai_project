import 'package:module_utils/module_utils.dart';

/// 指标 / 异常 / 性能追踪。
class RealtimeTelemetry {
  void metric(String name, {Map<String, dynamic>? params}) {
    _report(type: 'metric', name: name, params: params);
  }

  void error(String name, Object error, {Map<String, dynamic>? params}) {
    _report(
      type: 'error',
      name: name,
      params: {
        ...?params,
        'error': error.toString(),
      },
    );
  }

  void trace(String name, {required int durationMs, Map<String, dynamic>? params}) {
    _report(
      type: 'trace',
      name: name,
      params: {
        ...?params,
        'durationMs': durationMs,
      },
    );
  }

  void _report({
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
