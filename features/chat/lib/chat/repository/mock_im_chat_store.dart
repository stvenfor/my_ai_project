import 'dart:async';

import 'package:module_chat/chat/models/chat_avatar_urls.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_core/model/im/conversation_ref.dart';
import 'package:uuid/uuid.dart';

/// Mock IM 内存存储（Phase0+1；真实 SDK 接入后由 Engine 回调驱动同一结构）。
class MockImChatStore {
  MockImChatStore._();

  static final MockImChatStore instance = MockImChatStore._();

  final _uuid = const Uuid();
  final _conversations = <ConversationModel>[];
  final _messages = <String, List<MessageModel>>{};
  final _conversationController = StreamController<List<ConversationModel>>.broadcast();
  final _messageControllers = <String, StreamController<List<MessageModel>>>{};

  String? _selfImUserId;
  bool _seeded = false;

  Stream<List<ConversationModel>> get conversationsStream =>
      _conversationController.stream;

  void bindSelfImUserId(String? imUserId) {
    _selfImUserId = imUserId;
    _ensureSeed();
    _emitConversations();
  }

  Stream<List<MessageModel>> watchMessages(ConversationRef ref) {
    final key = ref.storageId;
    _messageControllers.putIfAbsent(
      key,
      () => StreamController<List<MessageModel>>.broadcast(),
    );
    _ensureSeed();
    _emitMessages(key);
    return _messageControllers[key]!.stream;
  }

  List<ConversationModel> get conversations => List.unmodifiable(_conversations);

  List<MessageModel> messagesOf(ConversationRef ref) =>
      List.unmodifiable(_messages[ref.storageId] ?? []);

  void _ensureSeed() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();
    const peers = ['mock_peer_01', 'mock_peer_02', 'mock_peer_03'];
    for (var i = 0; i < peers.length; i++) {
      final peer = peers[i];
      final ref = ConversationRef.private(peer);
      _conversations.add(
        ConversationModel.private(
          targetId: peer,
          title: 'Mock好友${i + 1}',
          portraitUrl: ChatAvatarUrls.peer(peer),
          lastMessage: i == 0 ? '晚上一起吃饭吗？' : '你好',
          lastMessageTime: now.subtract(Duration(minutes: 5 * (i + 1))),
          isOnline: i.isEven,
          unreadCount: i == 0 ? 2 : 0,
        ),
      );
      if (i == 0) {
        _messages[ref.storageId] = [
          MessageModel(
            id: 'm_1',
            messageUid: 'uid_m_1',
            conversationId: ref.storageId,
            type: MessageType.text,
            content: '你好，在吗？',
            isSelf: false,
            senderImUserId: peer,
            createdAt: now.subtract(const Duration(minutes: 30)),
            readStatus: MessageReadStatus.read,
          ),
          MessageModel(
            id: 'm_2',
            messageUid: 'uid_m_2',
            conversationId: ref.storageId,
            type: MessageType.text,
            content: '在的，有什么事？',
            isSelf: true,
            createdAt: now.subtract(const Duration(minutes: 28)),
            readStatus: MessageReadStatus.read,
          ),
        ];
      }
    }
  }

  Future<MessageModel> insertMessage({
    required ConversationRef ref,
    required MessageModel message,
  }) async {
    final list = _messages.putIfAbsent(ref.storageId, () => []);
    list.insert(0, message);
    _upsertConversationPreview(ref, message);
    _emitMessages(ref.storageId);
    _emitConversations();
    return message;
  }

  Future<void> removeMessage(ConversationRef ref, String messageId) async {
    final list = _messages[ref.storageId];
    if (list == null) return;
    list.removeWhere((m) => m.id == messageId);
    _emitMessages(ref.storageId);
  }

  Future<void> replaceMessage(ConversationRef ref, MessageModel message) async {
    final list = _messages[ref.storageId];
    if (list == null) return;
    final index = list.indexWhere((m) => m.id == message.id);
    if (index >= 0) {
      list[index] = message;
      _emitMessages(ref.storageId);
    }
  }

  Future<MessageModel?> findMessage(ConversationRef ref, String messageId) async {
    final list = _messages[ref.storageId];
    if (list == null) return null;
    for (final m in list) {
      if (m.id == messageId) return m;
    }
    return null;
  }

  Future<void> markRead(ConversationRef ref) async {
    final list = _messages[ref.storageId];
    if (list != null) {
      for (var i = 0; i < list.length; i++) {
        if (!list[i].isSelf && list[i].readStatus == MessageReadStatus.unread) {
          list[i] = list[i].copyWith(readStatus: MessageReadStatus.read);
        }
      }
      _emitMessages(ref.storageId);
    }
    final idx = _conversations.indexWhere((c) => c.id == ref.storageId);
    if (idx >= 0) {
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      _emitConversations();
    }
  }

  ConversationModel ensurePrivateConversation({
    required String peerImUserId,
    required String title,
    required String portraitUrl,
  }) {
    _ensureSeed();
    final ref = ConversationRef.private(peerImUserId);
    final existing = _conversations.where((c) => c.id == ref.storageId);
    if (existing.isNotEmpty) return existing.first;
    final conv = ConversationModel.private(
      targetId: peerImUserId,
      title: title,
      portraitUrl: portraitUrl,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
    );
    _conversations.insert(0, conv);
    _emitConversations();
    return conv;
  }

  String nextLocalId() => 'local_${_uuid.v4()}';

  String nextMessageUid() => 'uid_${DateTime.now().millisecondsSinceEpoch}';

  void _upsertConversationPreview(ConversationRef ref, MessageModel message) {
    final preview = switch (message.type) {
      MessageType.image => '[图片]',
      MessageType.voice => '[语音]',
      MessageType.custom => '[自定义消息]',
      MessageType.system => message.content,
      MessageType.time => null,
      MessageType.text => message.content,
    };
    if (preview == null) return;

    final idx = _conversations.indexWhere((c) => c.id == ref.storageId);
    if (idx >= 0) {
      _conversations[idx] = _conversations[idx].copyWith(
        lastMessage: preview,
        lastMessageTime: message.createdAt,
        unreadCount: message.isSelf
            ? _conversations[idx].unreadCount
            : _conversations[idx].unreadCount + 1,
      );
    } else if (ref.isPrivate) {
      _conversations.insert(
        0,
        ConversationModel.private(
          targetId: ref.targetId,
          title: message.senderDisplayName ?? ref.targetId,
          portraitUrl: ChatAvatarUrls.peer(ref.targetId),
          lastMessage: preview,
          lastMessageTime: message.createdAt,
          unreadCount: message.isSelf ? 0 : 1,
        ),
      );
    }
  }

  void _emitConversations() {
    final sorted = List<ConversationModel>.from(_conversations)
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    if (!_conversationController.isClosed) {
      _conversationController.add(sorted);
    }
  }

  void _emitMessages(String storageId) {
    final controller = _messageControllers[storageId];
    if (controller == null || controller.isClosed) return;
    controller.add(List<MessageModel>.from(_messages[storageId] ?? []));
  }

  /// 模拟对方已读（单聊）。
  Future<void> simulatePeerRead(ConversationRef ref, String messageId) async {
    final list = _messages[ref.storageId];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      if (list[i].id == messageId && list[i].isSelf) {
        list[i] = list[i].copyWith(readStatus: MessageReadStatus.read);
        _emitMessages(ref.storageId);
        return;
      }
    }
  }
}
