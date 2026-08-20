import 'package:flutter/foundation.dart';

/// 模块启动上下文：主工程集成模式或模块独立运行模式。
class ModuleHostContext {
  const ModuleHostContext({
    required this.isStandalone,
    this.enableHttpLog = kDebugMode,
    this.httpMaxRetries = 3,
  });

  factory ModuleHostContext.integrated({
    bool enableHttpLog = kDebugMode,
    int httpMaxRetries = 3,
  }) {
    return ModuleHostContext(
      isStandalone: false,
      enableHttpLog: enableHttpLog,
      httpMaxRetries: httpMaxRetries,
    );
  }

  factory ModuleHostContext.standalone({
    bool enableHttpLog = kDebugMode,
    int httpMaxRetries = 3,
  }) {
    return ModuleHostContext(
      isStandalone: true,
      enableHttpLog: enableHttpLog,
      httpMaxRetries: httpMaxRetries,
    );
  }

  final bool isStandalone;
  final bool enableHttpLog;
  final int httpMaxRetries;
}
