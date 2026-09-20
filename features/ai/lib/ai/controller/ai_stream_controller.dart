import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_ai/ai/model/ai_chat_message.dart';
import 'package:module_ai/ai/model/ai_stream_event.dart';
import 'package:module_ai/ai/repository/ai_stream_repository.dart';
import 'package:module_http/module_http.dart';

/// AI 小石头气泡页控制器：多轮气泡、单轮在途、停止生成、停留会话 id。
class AiStreamController extends GetxController {
  AiStreamController({AiStreamRepository? repository})
      : _repository = repository ?? AiStreamRepositoryImpl();

  final AiStreamRepository _repository;

  static const welcomeText =
      '你好，我是 AI 小石头——本 App / 4S 店的业务向导。'
      '你可以问「二手车入口在哪」「如何登录」或点下方快捷问。';

  static const List<String> quickPrompts = [
    '二手车入口在哪里？',
    '怎么登录账号？',
    '数据分析怎么看？',
  ];

  final messages = <AiChatMessage>[].obs;
  final isStreaming = false.obs;
  final conversationId = RxnString();

  late final ScrollController scrollController;
  late final TextEditingController textController;

  CancelToken? _cancelToken;
  int _seq = 0;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    textController = TextEditingController();
    messages.add(
      AiChatMessage(
        id: _nextId(),
        role: AiChatRole.welcome,
        text: welcomeText,
      ),
    );
  }

  @override
  void onClose() {
    _cancelToken?.cancel('dispose');
    _cancelToken = null;
    conversationId.value = null;
    messages.clear();
    scrollController.dispose();
    textController.dispose();
    super.onClose();
  }

  bool get canSend => !isStreaming.value;

  Future<void> sendQuickPrompt(String prompt) => send(prompt);

  Future<void> send(String rawPrompt) async {
    final prompt = rawPrompt.trim();
    if (prompt.isEmpty || isStreaming.value) return;

    messages.add(
      AiChatMessage(
        id: _nextId(),
        role: AiChatRole.user,
        text: prompt,
      ),
    );
    textController.clear();

    final assistant = AiChatMessage(
      id: _nextId(),
      role: AiChatRole.assistant,
      text: '',
      isStreaming: true,
    );
    messages.add(assistant);
    messages.refresh();
    _scrollToBottom();

    isStreaming.value = true;
    _cancelToken = CancelToken();
    final clientRequestId =
        'req_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await for (final event in _repository.streamCompletion(
        prompt: prompt,
        conversationId: conversationId.value,
        clientRequestId: clientRequestId,
        cancelToken: _cancelToken,
      )) {
        switch (event) {
          case AiStreamMeta(:final conversationId):
            if (conversationId != null && conversationId.isNotEmpty) {
              this.conversationId.value = conversationId;
            }
          case AiStreamDelta(:final text):
            assistant.text += text;
            messages.refresh();
            _scrollToBottom();
          case AiStreamDone():
            assistant.isStreaming = false;
            messages.refresh();
          case AiStreamError(:final message):
            assistant.isStreaming = false;
            assistant.errorMessage = message;
            messages.refresh();
        }
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        assistant.isStreaming = false;
        messages.refresh();
      } else {
        assistant.isStreaming = false;
        assistant.errorMessage = e.message ?? '网络异常';
        messages.refresh();
      }
    } on SseException catch (e) {
      assistant.isStreaming = false;
      assistant.errorMessage = _mapSseError(e);
      messages.refresh();
    } catch (e) {
      assistant.isStreaming = false;
      assistant.errorMessage = e.toString();
      messages.refresh();
    } finally {
      assistant.isStreaming = false;
      isStreaming.value = false;
      _cancelToken = null;
      messages.refresh();
    }
  }

  Future<void> stop() async {
    final token = _cancelToken;
    if (token == null || token.isCancelled) return;
    token.cancel('user_stop');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  String _nextId() => 'm_${++_seq}';

  String _mapSseError(SseException e) {
    switch (e.statusCode) {
      case 401:
      case 403:
        return '登录已失效，请重新登录';
      case 429:
        return '请求过于频繁，请稍后再试';
      case 503:
        return '服务暂不可用，请稍后再试';
      default:
        return e.message;
    }
  }
}
