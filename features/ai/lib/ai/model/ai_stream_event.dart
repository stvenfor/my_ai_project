sealed class AiStreamEvent {
  const AiStreamEvent();
}

class AiStreamMeta extends AiStreamEvent {
  const AiStreamMeta({
    this.requestId,
    this.conversationId,
    this.model,
    this.clientRequestId,
  });

  final String? requestId;
  final String? conversationId;
  final String? model;
  final String? clientRequestId;
}

class AiStreamDelta extends AiStreamEvent {
  const AiStreamDelta({required this.text});

  final String text;
}

class AiStreamDone extends AiStreamEvent {
  const AiStreamDone({this.finishReason});

  final String? finishReason;
}

class AiStreamError extends AiStreamEvent {
  const AiStreamError({
    required this.code,
    required this.message,
  });

  final String code;
  final String message;
}
