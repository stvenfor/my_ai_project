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

  AiChatMessage copyWith({
    String? text,
    String? errorMessage,
    bool? isStreaming,
    bool clearError = false,
  }) {
    return AiChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
