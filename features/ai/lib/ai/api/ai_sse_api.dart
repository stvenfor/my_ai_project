import 'dart:convert';

import 'package:module_ai/ai/model/ai_stream_event.dart';
import 'package:module_http/module_http.dart';

/// POST /api/v1/sse/completions — 打开 SSE 字节流并解析为领域事件。
class AiSseApi {
  AiSseApi({SseClient? client}) : _client = client ?? SseClient();

  static const completionsPath = '/api/v1/sse/completions';

  final SseClient _client;

  Stream<AiStreamEvent> streamCompletion({
    required String prompt,
    String? conversationId,
    String? clientRequestId,
    CancelToken? cancelToken,
  }) async* {
    final body = <String, dynamic>{
      'prompt': prompt,
      if (conversationId != null && conversationId.isNotEmpty)
        'conversationId': conversationId,
      if (clientRequestId != null && clientRequestId.isNotEmpty)
        'clientRequestId': clientRequestId,
    };

    await for (final frame in _client.post(
      completionsPath,
      data: body,
      cancelToken: cancelToken,
    )) {
      final event = _mapFrame(frame);
      if (event != null) yield event;
    }
  }

  AiStreamEvent? _mapFrame(SseFrame frame) {
    Map<String, dynamic>? json;
    if (frame.data.isNotEmpty) {
      try {
        final decoded = jsonDecode(frame.data);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        } else if (decoded is Map) {
          json = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    }

    final type = frame.event.isNotEmpty
        ? frame.event
        : (json?['type']?.toString() ?? 'message');

    switch (type) {
      case 'meta':
        return AiStreamMeta(
          requestId: json?['requestId']?.toString(),
          conversationId: json?['conversationId']?.toString(),
          model: json?['model']?.toString(),
          clientRequestId: json?['clientRequestId']?.toString(),
        );
      case 'delta':
        final text = json?['text']?.toString() ?? '';
        if (text.isEmpty) return null;
        return AiStreamDelta(text: text);
      case 'done':
        return AiStreamDone(finishReason: json?['finishReason']?.toString());
      case 'error':
        final err = json?['error'];
        String code = 'stream_error';
        String message = '生成失败';
        if (err is Map) {
          code = err['code']?.toString() ?? code;
          message = err['message']?.toString() ?? message;
        } else if (err != null) {
          message = err.toString();
        } else if (json?['message'] != null) {
          message = json!['message'].toString();
        }
        return AiStreamError(code: code, message: message);
      default:
        return null;
    }
  }
}
