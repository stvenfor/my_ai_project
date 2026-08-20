import 'package:dio/dio.dart';

import 'network_codes.dart';

/// 对齐 iOS `TFNetworkError` + 旧 Flutter 错误 Map。
class WysNetworkError implements Exception {
  WysNetworkError({
    required this.message,
    this.code,
    this.httpStatusCode,
    this.dioException,
    this.responseBody,
  });

  final String message;
  final int? code;
  final int? httpStatusCode;
  final DioException? dioException;
  final dynamic responseBody;

  @override
  String toString() => 'WysNetworkError($code, $httpStatusCode): $message';

  static const defaultMessage = '网络和服务故障，请稍后重试。';

  factory WysNetworkError.fromDio(DioException e) {
    final status = e.response?.statusCode;
    var msg = defaultMessage;

    final data = e.response?.data;
    if (data is Map) {
      final desc = data['error_description'] ?? data['message'];
      if (desc != null && desc.toString().isNotEmpty) {
        msg = desc.toString();
      }
    }
    if (msg == defaultMessage && e.message != null && e.message!.isNotEmpty) {
      msg = e.message!;
    }

    return WysNetworkError(
      message: msg,
      code: e.error is int ? e.error as int : null,
      httpStatusCode: status,
      dioException: e,
      responseBody: data,
    );
  }

  factory WysNetworkError.business({
    required int code,
    required String message,
    dynamic responseBody,
  }) {
    return WysNetworkError(
      message: message,
      code: code,
      responseBody: responseBody,
    );
  }

  bool get isTokenExpired =>
      httpStatusCode == NetworkCodes.expireToken ||
      code == NetworkCodes.expireToken;

  bool get isBusy =>
      httpStatusCode == NetworkCodes.busy || code == NetworkCodes.busy;
}