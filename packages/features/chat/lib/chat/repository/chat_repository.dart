import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';

/// 聊天数据抽象，后续可替换为 Supabase Realtime / WebSocket 实现。
abstract class ChatRepository {
  Future<List<ConversationModel>> fetchConversations();

  Future<List<MessageModel>> fetchMessages(String conversationId);

  Future<MessageModel> sendMessage(MessageModel message);

  Future<void> deleteMessage(String conversationId, String messageId);

  Future<MessageModel> recallMessage(String conversationId, String messageId);

  Future<void> markMessagesRead(String conversationId, List<String> messageIds);
}
