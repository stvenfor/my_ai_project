import 'package:module_chat/chat/models/chat_avatar_urls.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/repository/chat_repository.dart';

class MockChatRepository implements ChatRepository {
  MockChatRepository._();

  static final MockChatRepository instance = MockChatRepository._();

  final Map<String, List<MessageModel>> _messagesByConversation = {};
  final List<ConversationModel> _conversations = [];

  bool _initialized = false;

  void _ensureSeed() {
    if (_initialized) return;
    _initialized = true;

    final now = DateTime.now();
    _conversations.addAll([
      ConversationModel(
        id: 'conv_1',
        peerId: 'user_1',
        peerName: '张三',
        peerAvatar: ChatAvatarUrls.peer('user_1'),
        lastMessage: '晚上一起吃饭吗？',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        isOnline: true,
        unreadCount: 2,
      ),
      ConversationModel(
        id: 'conv_2',
        peerId: 'user_2',
        peerName: '李四',
        peerAvatar: ChatAvatarUrls.peer('user_2'),
        lastMessage: '[图片]',
        lastMessageTime: now.subtract(const Duration(hours: 2)),
        isOnline: false,
        unreadCount: 0,
      ),
      ConversationModel(
        id: 'conv_3',
        peerId: 'user_3',
        peerName: '王五',
        peerAvatar: ChatAvatarUrls.peer('user_3'),
        lastMessage: '收到，谢谢',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        isOnline: true,
        unreadCount: 0,
      ),
    ]);

    _messagesByConversation['conv_1'] = [
      MessageModel(
        id: 'm_t1',
        conversationId: 'conv_1',
        type: MessageType.time,
        content: _formatTime(now.subtract(const Duration(hours: 1))),
        isSelf: false,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      MessageModel(
        id: 'm_1',
        conversationId: 'conv_1',
        type: MessageType.text,
        content: '你好，在吗？',
        isSelf: false,
        createdAt: now.subtract(const Duration(minutes: 30)),
        readStatus: MessageReadStatus.read,
      ),
      MessageModel(
        id: 'm_2',
        conversationId: 'conv_1',
        type: MessageType.text,
        content: '在的，有什么事？',
        isSelf: true,
        createdAt: now.subtract(const Duration(minutes: 28)),
        readStatus: MessageReadStatus.read,
      ),
      MessageModel(
        id: 'm_3',
        conversationId: 'conv_1',
        type: MessageType.image,
        content: 'https://picsum.photos/400/300',
        isSelf: false,
        createdAt: now.subtract(const Duration(minutes: 20)),
        readStatus: MessageReadStatus.unread,
      ),
      MessageModel(
        id: 'm_4',
        conversationId: 'conv_1',
        type: MessageType.voice,
        content: '',
        isSelf: true,
        createdAt: now.subtract(const Duration(minutes: 10)),
        voiceDurationSeconds: 5,
        readStatus: MessageReadStatus.read,
      ),
      MessageModel(
        id: 'm_5',
        conversationId: 'conv_1',
        type: MessageType.text,
        content: '晚上一起吃饭吗？',
        isSelf: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
        readStatus: MessageReadStatus.unread,
      ),
    ];
  }

  static String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  List<MessageModel> _messages(String conversationId) {
    _ensureSeed();
    return _messagesByConversation.putIfAbsent(conversationId, () => []);
  }

  @override
  Future<List<ConversationModel>> fetchConversations() async {
    _ensureSeed();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<ConversationModel>.from(_conversations)
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  @override
  Future<List<MessageModel>> fetchMessages(String conversationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return List<MessageModel>.from(_messages(conversationId));
  }

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final saved = message.copyWith(sendStatus: MessageSendStatus.success);
    _messages(message.conversationId).insert(0, saved);
    _updateConversationPreview(message.conversationId, saved);
    return saved;
  }

  void _updateConversationPreview(String conversationId, MessageModel message) {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index < 0) return;
    final preview = switch (message.type) {
      MessageType.image => '[图片]',
      MessageType.voice => '[语音]',
      MessageType.system => message.content,
      MessageType.time => _conversations[index].lastMessage,
      MessageType.text => message.content,
    };
    _conversations[index] = _conversations[index].copyWith(
      lastMessage: preview,
      lastMessageTime: message.createdAt,
    );
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    _messages(conversationId).removeWhere((m) => m.id == messageId);
  }

  @override
  Future<MessageModel> recallMessage(String conversationId, String messageId) async {
    final list = _messages(conversationId);
    final index = list.indexWhere((m) => m.id == messageId);
    if (index < 0) {
      throw StateError('消息不存在');
    }
    final original = list[index];
    if (!original.canRecall) {
      throw StateError('消息不可撤回');
    }
    final systemMsg = MessageModel(
      id: 'sys_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      type: MessageType.system,
      content: '你撤回了一条消息',
      isSelf: true,
      createdAt: DateTime.now(),
    );
    list[index] = systemMsg;
    return systemMsg;
  }

  @override
  Future<void> markMessagesRead(
    String conversationId,
    List<String> messageIds,
  ) async {
    final list = _messages(conversationId);
    for (var i = 0; i < list.length; i++) {
      if (messageIds.contains(list[i].id)) {
        list[i] = list[i].copyWith(readStatus: MessageReadStatus.read);
      }
    }
    final convIndex = _conversations.indexWhere((c) => c.id == conversationId);
    if (convIndex >= 0) {
      _conversations[convIndex] =
          _conversations[convIndex].copyWith(unreadCount: 0);
    }
  }
}
