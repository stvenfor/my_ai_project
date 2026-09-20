import 'dart:convert';

/// SSE 流前（尚未升级为 event-stream）或协议层失败。
class SseException implements Exception {
  SseException({
    required this.message,
    this.statusCode,
    this.error,
    this.rawBody,
  });

  factory SseException.fromPreStream({
    required int statusCode,
    required String body,
  }) {
    String? errorField;
    String message = body.trim().isEmpty
        ? 'SSE request failed ($statusCode)'
        : body.trim();
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final err = decoded['error'];
        if (err != null) {
          errorField = err.toString();
          message = errorField;
        } else if (decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      }
    } catch (_) {
      // 非 JSON 时保留原始文本
    }
    return SseException(
      message: message,
      statusCode: statusCode,
      error: errorField ?? _defaultErrorCode(statusCode),
      rawBody: body,
    );
  }

  final String message;
  final int? statusCode;

  /// 稳定错误码：如 unauthorized / rate_limited / 或 JSON `error` 字段。
  final String? error;
  final String? rawBody;

  static String _defaultErrorCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'bad_request';
      case 401:
        return 'unauthorized';
      case 403:
        return 'forbidden';
      case 404:
        return 'not_found';
      case 429:
        return 'rate_limited';
      case 503:
        return 'unavailable';
      default:
        return 'http_$statusCode';
    }
  }

  @override
  String toString() =>
      'SseException(message: $message, statusCode: $statusCode, error: $error)';
}
