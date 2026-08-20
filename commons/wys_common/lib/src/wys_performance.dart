import 'package:flutter/foundation.dart';

/// 性能优化功能开关。可通过 dart-define 单独关闭，快速回退到原流程。
abstract final class WysPerformanceFlags {
  WysPerformanceFlags._();

  static const bool splashAdDiskCache = bool.fromEnvironment(
    'TF_SPLASH_AD_DISK_CACHE',
    defaultValue: true,
  );
  static const bool progressiveHomeLoading = bool.fromEnvironment(
    'TF_PROGRESSIVE_HOME_LOADING',
    defaultValue: true,
  );
  static const bool deferredNonCriticalInit = bool.fromEnvironment(
    'TF_DEFERRED_NON_CRITICAL_INIT',
    defaultValue: true,
  );
}

/// 轻量性能时序日志。只记录阶段和耗时，不记录账号、Token 等敏感数据。
abstract final class WysPerformanceTrace {
  WysPerformanceTrace._();

  static final Stopwatch _appStopwatch = Stopwatch()..start();
  static final String traceId = DateTime.now().microsecondsSinceEpoch
      .toRadixString(36);

  static int get elapsedMilliseconds => _appStopwatch.elapsedMilliseconds;

  static void mark(String stage, {Map<String, Object?> data = const {}}) {
    if (!kDebugMode && !kProfileMode) return;
    final details = data.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${entry.value}')
        .join(', ');
    debugPrint(
      '[PERF_TRACE] traceId=$traceId, elapsedMs=$elapsedMilliseconds, '
      'stage=$stage${details.isEmpty ? '' : ', $details'}',
    );
  }
}
