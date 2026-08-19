import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class LogPrintInterceptor extends Interceptor {
  LogPrintInterceptor({
    void Function(String message)? logger,
  }) : _logger = logger ?? _defaultLogger;

  final void Function(String message) _logger;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _logger('--> ${options.method} ${options.uri}');
    if (options.headers.isNotEmpty) {
      _logger('headers: ${_redactHeaders(options.headers)}');
    }
    if (options.queryParameters.isNotEmpty) {
      _logger('query: ${options.queryParameters}');
    }
    if (options.data != null) {
      _logger('body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final request = response.requestOptions;
    _logger(
      '<-- ${response.statusCode} ${request.method} ${request.uri}',
    );
    _logger('response: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final request = err.requestOptions;
    _logger(
      '<-- error ${request.method} ${request.uri}: ${err.message}',
    );
    if (err.response?.data != null) {
      _logger('error response: ${err.response?.data}');
    }
    handler.next(err);
  }

  static Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final result = Map<String, dynamic>.of(headers);
    for (final key in result.keys.toList()) {
      final lowerKey = key.toLowerCase();
      if (lowerKey == 'authorization' ||
          lowerKey == 'cookie' ||
          lowerKey == 'set-cookie') {
        result[key] = '***';
      }
    }
    return result;
  }

  static void _defaultLogger(String message) {
    developer.log(message, name: 'module_http');
  }
}
