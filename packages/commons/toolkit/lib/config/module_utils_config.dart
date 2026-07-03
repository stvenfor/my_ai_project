import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// 工具模块启动配置。
class ModuleUtilsConfig {
  const ModuleUtilsConfig({
    this.designSize = const Size(375, 812),
    this.minTextAdapt = true,
    this.splitScreenMode = true,
    this.enableLog = kDebugMode,
    this.logLevel,
    this.logTag,
  });

  final Size designSize;
  final bool minTextAdapt;
  final bool splitScreenMode;
  final bool enableLog;
  final Level? logLevel;
  final String? logTag;

  Level get resolvedLogLevel {
    if (logLevel != null) return logLevel!;
    return enableLog ? Level.debug : Level.warning;
  }
}
