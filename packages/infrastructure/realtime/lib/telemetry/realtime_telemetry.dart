import 'package:module_realtime/telemetry/realtime_telemetry_reporter.dart';

/// 指标 / 异常 / 性能追踪。
class RealtimeTelemetry {
  void metric(String name, {Map<String, dynamic>? params}) {
    RealtimeTelemetryReporter.report(
      type: 'metric',
      name: name,
      params: params,
    );
  }

  void error(String name, Object error, {Map<String, dynamic>? params}) {
    RealtimeTelemetryReporter.report(
      type: 'error',
      name: name,
      params: {
        ...?params,
        'error': error.toString(),
      },
    );
  }

  void trace(String name, {required int durationMs, Map<String, dynamic>? params}) {
    RealtimeTelemetryReporter.report(
      type: 'trace',
      name: name,
      params: {
        ...?params,
        'durationMs': durationMs,
      },
    );
  }
}
