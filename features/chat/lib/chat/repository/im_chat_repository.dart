import 'dart:async';

import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/repository/chat_repository.dart';
import 'package:module_chat/chat/repository/mock_im_chat_store.dart';
import 'package:module_core/model/im/conversation_ref.dart';
import 'package:module_core/model/im/im_session_state.dart';
import 'package:module_core/service/im_backup_service.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_core/service/im_user_profile_service.dart';

/// 融云 IM ChatRepository（Mock Engine + 备份 + 资料缓存）。
class ImChatRepository implements ChatRepository {
  ImChatRepository({
    required ImSessionService sessionService,
    required ImUserProfileService profileService,
    required ImBackupService backupService,
    MockImChatStore? store,
  })  : _session = sessionService,
        _profileService = profileService,
        _backup = backupService,
        _store = store ?? MockImChatStore.instance;

  final ImSessionService _session;
  final ImUserProfileService _profileService;
  final ImBackupService _backup;
  final MockImChatStore _store;

  @override
  Stream<List<ConversationModel>> watchConversations() {
    _bindSelfIfNeeded();
    return _store.conversationsStream;
  }

  @override
  Future<void> refreshConversations() async {
    _requireConnected();
    _bindSelfIfNeeded();
    await _hydrateConversationProfiles();
  }

  @override
  Stream<List<MessageModel>> watchMessages(ConversationRef ref) {
    _bindSelfIfNeeded();
    return _store.watchMessages(ref);
  }

  @override
  Future<List<MessageModel>> loadHistory(
    ConversationRef ref, {
    String? beforeMessageId,
    int limit = 20,
  }) async {
    _requireConnected();
    var list = _store.messagesOf(ref);
    if (beforeMessageId != null) {
      final idx = list.indexWhere((m) => m.id == beforeMessageId);
      if (idx >= 0) {
        list = list.sublist(idx + 1);
      }
    }
    if (list.length > limit) {
      list = list.sublist(0, limit);
    }
    return list;
  }

  @override
  Future<MessageModel> sendText(ConversationRef ref, String text) {
    return _send(
      ref,
      type: MessageType.text,
      content: text,
      backupType: 'text',
      payload: {'text': text},
    );
  }

  @override
  Future<MessageModel> sendImage(ConversationRef ref, String localPath) {
    return _send(
      ref,
      type: MessageType.image,
      content: localPath,
      localPath: localPath,
      backupType: 'image',
      payload: {'localPath': localPath},
    );
  }

  @override
  Future<MessageModel> sendVoice(
    ConversationRef ref,
    String localPath,
    int durationSeconds,
  ) {
    return _send(
      ref,
      type: MessageType.voice,
      content: localPath,
      localPath: localPath,
      voiceDurationSeconds: durationSeconds,
      backupType: 'voice',
      payload: {'localPath': localPath, 'duration': durationSeconds},
    );
  }

  @override
  Future<MessageModel> sendCustom(
    ConversationRef ref,
    String customType,
    Map<String, dynamic> payload,
  ) {
    return _send(
      ref,
      type: MessageType.custom,
      content: customType,
      customType: customType,
      customPayload: payload,
      backupType: 'custom',
      payload: {'customType': customType, ...payload},
    );
  }

  Future<MessageModel> _send(
    ConversationRef ref, {
    required MessageType type,
    required String content,
    required String backupType,
    required Map<String, dynamic> payload,
    String? localPath,
    int voiceDurationSeconds = 0,
    String? customType,
    Map<String, dynamic> customPayload = const {},
  }) async {
    _requireConnected();
    final imUserId = _session.currentImUserId!;
    final localId = _store.nextLocalId();
    final uid = _store.nextMessageUid();

    var pending = MessageModel(
      id: localId,
      messageUid: uid,
      conversationId: ref.storageId,
      type: type,
      content: content,
      isSelf: true,
      createdAt: DateTime.now(),
      sendStatus: MessageSendStatus.sending,
      readStatus: MessageReadStatus.unread,
      voiceDurationSeconds: voiceDurationSeconds,
      customType: customType,
      customPayload: customPayload,
      localPath: localPath,
    );
    await _store.insertMessage(ref: ref, message: pending);

    await Future<void>.delayed(const Duration(milliseconds: 280));

    final saved = pending.copyWith(sendStatus: MessageSendStatus.success);
    await _store.replaceMessage(ref, saved);

    unawaited(
      _backup.backupOutbound(
        imUserId: imUserId,
        conversationId: ref.storageId,
        messageUid: uid,
        type: backupType,
        payload: payload,
        sentAt: saved.createdAt,
      ),
    );

    if (ref.isPrivate) {
      unawaited(
        Future.delayed(const Duration(seconds: 2), () {
          _store.simulatePeerRead(ref, localId);
        }),
      );
    }

    return saved;
  }

  @override
  Future<void> recallMessage(ConversationRef ref, String messageId) async {
    _requireConnected();
    final original = await _store.findMessage(ref, messageId);
    if (original == null) throw StateError('消息不存在');
    if (!original.canRecall) throw StateError('消息不可撤回');

    final systemMsg = MessageModel(
      id: messageId,
      messageUid: original.messageUid,
      conversationId: ref.storageId,
      type: MessageType.system,
      content: '你撤回了一条消息',
      isSelf: true,
      createdAt: DateTime.now(),
    );
    await _store.replaceMessage(ref, systemMsg);

    final imUserId = _session.currentImUserId;
    if (imUserId != null && original.messageUid != null) {
      unawaited(
        _backup.backupRecall(
          imUserId: imUserId,
          conversationId: ref.storageId,
          messageUid: original.messageUid!,
          recalledAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> deleteMessage(ConversationRef ref, String messageId) async {
    _requireConnected();
    await _store.removeMessage(ref, messageId);
  }

  @override
  Future<void> markConversationRead(ConversationRef ref) async {
    _requireConnected();
    await _store.markRead(ref);
  }

  @override
  Future<ConversationModel> ensurePrivateConversation(String peerImUserId) async {
    _requireConnected();
    final profile = await _profileService.getProfile(peerImUserId);
    return _store.ensurePrivateConversation(
      peerImUserId: peerImUserId,
      title: profile?.displayName ?? peerImUserId,
      portraitUrl: profile?.avatarUrl ?? '',
    );
  }

  Future<void> _hydrateConversationProfiles() async {
    final ids = _store.conversations
        .where((c) => c.isPrivate)
        .map((c) => c.targetId)
        .toList();
    if (ids.isEmpty) return;
    await _profileService.prefetch(ids);
  }

  void _bindSelfIfNeeded() {
    final imUserId = _session.currentImUserId;
    _store.bindSelfImUserId(imUserId);
  }

  void _requireConnected() {
    if (_session.currentState != ImConnectionState.connected) {
      throw StateError('IM 未连接');
    }
  }
}

ImChatRepository? _registeredRepo;

ChatRepository resolveChatRepository() {
  if (Get.isRegistered<ChatRepository>()) {
    return Get.find<ChatRepository>();
  }
  if (_registeredRepo != null) return _registeredRepo!;
  if (Get.isRegistered<ImSessionService>() &&
      Get.isRegistered<ImUserProfileService>() &&
      Get.isRegistered<ImBackupService>()) {
    return ImChatRepository(
      sessionService: Get.find<ImSessionService>(),
      profileService: Get.find<ImUserProfileService>(),
      backupService: Get.find<ImBackupService>(),
    );
  }
  throw StateError('ChatRepository 未注册，请先 ImInitializer.initDeferred()');
}
