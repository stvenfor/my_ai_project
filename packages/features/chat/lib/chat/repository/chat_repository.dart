import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_core/model/im/conversation_ref.dart';

/// IM 聊天数据抽象（单聊 Phase0+1；群聊 Phase2 扩展）。
abstract class ChatRepository {
  Stream<List<ConversationModel>> watchConversations();

  Future<void> refreshConversations();

  Stream<List<MessageModel>> watchMessages(ConversationRef ref);

  Future<List<MessageModel>> loadHistory(
    ConversationRef ref, {
    String? beforeMessageId,
    int limit = 20,
  });

  Future<MessageModel> sendText(ConversationRef ref, String text);

  Future<MessageModel> sendImage(ConversationRef ref, String localPath);

  Future<MessageModel> sendVoice(
    ConversationRef ref,
    String localPath,
    int durationSeconds,
  );

  Future<MessageModel> sendCustom(
    ConversationRef ref,
    String customType,
    Map<String, dynamic> payload,
  );

  Future<void> recallMessage(ConversationRef ref, String messageId);

  Future<void> deleteMessage(ConversationRef ref, String messageId);

  Future<void> markConversationRead(ConversationRef ref);

  /// 打开单聊（若不存在则创建会话项）。
  Future<ConversationModel> ensurePrivateConversation(String peerImUserId);
}
