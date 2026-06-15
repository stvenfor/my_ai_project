import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 日志工具，基于 logger 包。
class LogUtils {
  LogUtils._();

  static Logger? _logger;
  static bool _configured = false;

  static Logger get _log {
    if (_logger != null) return _logger!;
    return _logger = _createDefaultLogger();
  }

  /// 启动阶段注册日志（由 [ModuleUtilsInitializer] 调用）。
  static void setup({
    Level level = Level.debug,
    bool enableColors = true,
    String? tag,
  }) {
    _logger = Logger(
      level: level,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 100,
        colors: enableColors,
        printEmojis: true,
      ),
    );
    _configured = true;
    if (tag != null && tag.isNotEmpty) {
      i('[$tag] logger ready, level=${level.name}');
    }
  }

  static void d(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _log.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _log.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _log.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _log.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _log.f(message, error: error, stackTrace: stackTrace);
  }

  /// 自定义 Logger 实例。
  static void configure(Logger logger) {
    _logger = logger;
    _configured = true;
  }

  static bool get isConfigured => _configured;

  static Logger _createDefaultLogger() {
    return Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 100,
        colors: !kIsWeb,
        printEmojis: true,
      ),
      level: kDebugMode ? Level.debug : Level.warning,
    );
  }
}
