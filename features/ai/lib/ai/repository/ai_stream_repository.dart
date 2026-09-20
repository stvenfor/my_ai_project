import 'package:module_ai/ai/api/ai_sse_api.dart';
import 'package:module_ai/ai/model/ai_stream_event.dart';
import 'package:module_http/module_http.dart';

/// AI 流式生成仓储：将 SSE 解包为 [AiStreamEvent]（测试可注入 fake）。
abstract class AiStreamRepository {
  Stream<AiStreamEvent> streamCompletion({
    required String prompt,
    String? conversationId,
    String? clientRequestId,
    CancelToken? cancelToken,
  });
}

class AiStreamRepositoryImpl implements AiStreamRepository {
  AiStreamRepositoryImpl({AiSseApi? api}) : _api = api ?? AiSseApi();

  final AiSseApi _api;

  @override
  Stream<AiStreamEvent> streamCompletion({
    required String prompt,
    String? conversationId,
    String? clientRequestId,
    CancelToken? cancelToken,
  }) {
    return _api.streamCompletion(
      prompt: prompt,
      conversationId: conversationId,
      clientRequestId: clientRequestId,
      cancelToken: cancelToken,
    );
  }
}
