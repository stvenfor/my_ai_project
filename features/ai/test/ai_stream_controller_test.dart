import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:module_ai/ai/controller/ai_stream_controller.dart';
import 'package:module_ai/ai/model/ai_chat_message.dart';
import 'package:module_ai/ai/model/ai_stream_event.dart';
import 'package:module_ai/ai/repository/ai_stream_repository.dart';
import 'package:module_http/module_http.dart';

class _FakeRepo implements AiStreamRepository {
  _FakeRepo(this._factory);

  final Stream<AiStreamEvent> Function({
    required String prompt,
    String? conversationId,
    CancelToken? cancelToken,
  }) _factory;

  int callCount = 0;

  @override
  Stream<AiStreamEvent> streamCompletion({
    required String prompt,
    String? conversationId,
    String? clientRequestId,
    CancelToken? cancelToken,
  }) {
    callCount++;
    return _factory(
      prompt: prompt,
      conversationId: conversationId,
      cancelToken: cancelToken,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiStreamController facade', () {
    test('appends deltas and stores conversationId from meta', () async {
      final repo = _FakeRepo(({
        required prompt,
        conversationId,
        cancelToken,
      }) async* {
        yield const AiStreamMeta(conversationId: 'conv_1');
        yield const AiStreamDelta(text: '你');
        yield const AiStreamDelta(text: '好');
        yield const AiStreamDone(finishReason: 'stop');
      });

      final c = AiStreamController(repository: repo);
      c.onInit();
      addTearDown(c.onClose);

      await c.send('hi');

      expect(c.conversationId.value, 'conv_1');
      expect(c.isStreaming.value, isFalse);
      final assistant = c.messages.lastWhere(
        (m) => m.role == AiChatRole.assistant,
      );
      expect(assistant.text, '你好');
      expect(assistant.errorMessage, isNull);
      expect(assistant.isStreaming, isFalse);
    });

    test('stop keeps partial text and ends streaming', () async {
      final repo = _FakeRepo(({
        required prompt,
        conversationId,
        cancelToken,
      }) async* {
        yield const AiStreamMeta(conversationId: 'conv_x');
        yield const AiStreamDelta(text: '半截');
        // 模拟长流：直到 CancelToken 被取消
        while (cancelToken == null || !cancelToken.isCancelled) {
          await Future<void>.delayed(const Duration(milliseconds: 15));
        }
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.cancel,
          error: 'user_stop',
        );
      });

      final c = AiStreamController(repository: repo);
      c.onInit();
      addTearDown(c.onClose);

      final sendFuture = c.send('stop me');
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(c.isStreaming.value, isTrue);

      await c.stop();
      await sendFuture;

      expect(c.isStreaming.value, isFalse);
      final assistant = c.messages.lastWhere(
        (m) => m.role == AiChatRole.assistant,
      );
      expect(assistant.text, '半截');
    });

    test('single in-flight rejects second send while streaming', () async {
      final release = Completer<void>();
      final repo = _FakeRepo(({
        required prompt,
        conversationId,
        cancelToken,
      }) async* {
        yield const AiStreamDelta(text: 'a');
        await release.future;
        yield const AiStreamDone();
      });

      final c = AiStreamController(repository: repo);
      c.onInit();
      addTearDown(c.onClose);

      final first = c.send('one');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await c.send('two');
      expect(repo.callCount, 1);

      release.complete();
      await first;
      expect(repo.callCount, 1);
    });

    test('error keeps partial text and sets bubble error', () async {
      final repo = _FakeRepo(({
        required prompt,
        conversationId,
        cancelToken,
      }) async* {
        yield const AiStreamDelta(text: '已生成');
        yield const AiStreamError(code: 'upstream_timeout', message: '超时了');
      });

      final c = AiStreamController(repository: repo);
      c.onInit();
      addTearDown(c.onClose);

      await c.send('fail');

      final assistant = c.messages.lastWhere(
        (m) => m.role == AiChatRole.assistant,
      );
      expect(assistant.text, '已生成');
      expect(assistant.errorMessage, '超时了');
      expect(c.isStreaming.value, isFalse);
    });

    test('onClose clears conversationId and messages', () async {
      final repo = _FakeRepo(({
        required prompt,
        conversationId,
        cancelToken,
      }) async* {
        yield const AiStreamMeta(conversationId: 'conv_gone');
        yield const AiStreamDone();
      });

      final c = AiStreamController(repository: repo);
      c.onInit();
      await c.send('x');
      expect(c.conversationId.value, 'conv_gone');
      expect(c.messages, isNotEmpty);

      c.onClose();
      expect(c.conversationId.value, isNull);
      expect(c.messages, isEmpty);
    });
  });
}
