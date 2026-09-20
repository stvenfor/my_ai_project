import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../http/http.dart';
import 'sse_exception.dart';
import 'sse_frame.dart';
import 'sse_parser.dart';

/// 基于 [HttpManager.instance.dio] 的 SSE 客户端（与 JSON `request` 路径分离）。
///
/// - `ResponseType.stream` + `Accept: text/event-stream`
/// - `receiveTimeout: Duration.zero`（长连接）
/// - Bearer / Session 仍由现有 HeaderInterceptor 注入；本类覆盖 Accept
/// - [CancelToken] 可中止消费
class SseClient {
  SseClient({Dio? dio}) : _dioOverride = dio;

  final Dio? _dioOverride;

  Dio get _dio => _dioOverride ?? HttpManager.instance.dio;

  /// POST 打开 SSE，成功时 yield 解析后的 [SseFrame]；注释 keepalive 已被解析器忽略。
  Stream<SseFrame> post(
    String path, {
    Object? data,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Duration sendTimeout = const Duration(seconds: 30),
  }) async* {
    final Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        path,
        data: data,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: Duration.zero,
          sendTimeout: sendTimeout,
          headers: <String, dynamic>{
            Headers.acceptHeader: 'text/event-stream',
            ...?headers,
          },
          validateStatus: (status) => status != null && status < 600,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) rethrow;
      final status = e.response?.statusCode;
      final body = await _tryReadErrorBody(e.response?.data);
      if (status != null && body != null) {
        throw SseException.fromPreStream(statusCode: status, body: body);
      }
      throw SseException(
        message: e.message ?? 'SSE connection failed',
        statusCode: status,
        error: 'connection_error',
      );
    }

    final status = response.statusCode ?? 0;
    final contentType =
        response.headers.value(Headers.contentTypeHeader) ?? '';
    final body = response.data;
    if (body == null) {
      throw SseException(
        message: 'Empty SSE response body',
        statusCode: status,
        error: 'empty_body',
      );
    }

    final isEventStream = contentType.toLowerCase().contains(
          'text/event-stream',
        );
    if (status != 200 || !isEventStream) {
      final raw = await _readResponseBody(body);
      throw SseException.fromPreStream(statusCode: status, body: raw);
    }

    yield* parseSseByteStream(body.stream, cancelToken: cancelToken);
  }
}

/// 将字节流解码并解析为 [SseFrame]；[cancelToken] 取消时停止 yield。
Stream<SseFrame> parseSseByteStream(
  Stream<Uint8List> byteStream, {
  CancelToken? cancelToken,
}) async* {
  final parser = SseParser();
  await for (final chunk in utf8.decoder.bind(byteStream)) {
    if (cancelToken != null && cancelToken.isCancelled) {
      return;
    }
    for (final frame in parser.add(chunk)) {
      yield frame;
    }
  }
  for (final frame in parser.flush()) {
    yield frame;
  }
}

Future<String> _readResponseBody(ResponseBody body) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in body.stream) {
    builder.add(chunk);
  }
  return utf8.decode(builder.takeBytes(), allowMalformed: true);
}

Future<String?> _tryReadErrorBody(Object? data) async {
  if (data == null) return null;
  if (data is ResponseBody) {
    return _readResponseBody(data);
  }
  if (data is String) return data;
  if (data is List<int>) {
    return utf8.decode(data, allowMalformed: true);
  }
  return data.toString();
}
