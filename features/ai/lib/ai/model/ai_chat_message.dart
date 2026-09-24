enum AiChatRole { user, assistant, welcome }

class AiChatMessage {
  AiChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.errorMessage,
    this.isStreaming = false,
  });

  final String id;
  final AiChatRole role;
  String text;
  String? errorMessage;
  bool isStreaming;
}
