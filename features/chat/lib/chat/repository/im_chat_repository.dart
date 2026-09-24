import 'dart:async';

import 'package:get/get.dart';
import 'package:module_chat/chat/models/chat_avatar_urls.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/repository/chat_repository.dart';
import 'package:module_chat/chat/repository/mock_im_chat_store.dart';
import 'package:module_chat/chat/repository/rong_sdk_mapper.dart';
import 'package:module_core/model/im/conversation_ref.dart';
import 'package:module_core/model/im/im_session_state.dart';
import 'package:module_core/service/im_backup_service.dart';
import 'package:module_core/service/im_session_service.dart';
import 'package:module_core/service/im_user_profile_service.dart';
import 'package:module_rongcloud_im/engine/rong_engine_holder.dart';
import 'package:module_utils/module_utils.dart';

/// 融云 IM ChatRepository：Mock 走内存种子；真连走 SDK，本地 store 仅作 UI 缓存。
class ImChatRepository implements ChatRepository {
  ImChatRepository({
    required ImSessionService sessionService,
    required ImUserProfileService profileService,
    required ImBackupService backupService,
    MockImChatStore? store,
    RongEngineHolder? engineHolder,
  })  : _session = sessionService,
        _profileService = profileService,
        _backup = backupService,
        _store = store ?? MockImChatStore.instance,
        _engineHolder = engineHolder;

  final ImSessionService _session;
  final ImUserProfileService _profileService;
  final ImBackupService _backup;
  final MockImChatStore _store;
  final RongEngineHolder? _engineHolder;
  bool _listenerWired = false;

  RongEngineHolder? get _engine {
    if (_engineHolder != null) return _engineHolder;
    if (Get.isRegistered<RongEngineHolder>()) {
      return Get.find<RongEngineHolder>();
    }
    return null;
  }

  bool get _sdk => _engine?.isSdkReady == true;

  @override
  Stream<List<ConversationModel>> watchConversations() {
    _bindSelfIfNeeded();
    _wireListenerIfNeeded();
    return _store.conversationsStream;
  }

  @override
  Future<void> refreshConversations() async {
    _requireConnected();
    _bindSelfIfNeeded();
    _wireListenerIfNeeded();
    if (_sdk) {
      await _pullConversationsFromSdk();
    }
    await _hydrateConversationProfiles();
  }

  @override
  Stream<List<MessageModel>> watchMessages(ConversationRef ref) {
    _bindSelfIfNeeded();
    _wireListenerIfNeeded();
    if (_sdk) {
      unawaited(_pullHistoryFromSdk(ref));
    }
    return _store.watchMessages(ref);
  }

  @override
  Future<List<MessageModel>> loadHistory(
    ConversationRef ref, {
    String? beforeMessageId,
    int limit = 20,
  }) async {
    _requireConnected();
    if (_sdk) {
      await _pullHistoryFromSdk(ref, limit: limit);
    }
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

    var pending = MessageModel(
      id: localId,
      messageUid: null,
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

    try {
      MessageModel saved;
      if (_sdk && type != MessageType.custom) {
        saved = await _sendViaSdk(
          ref,
          pending: pending,
          type: type,
          content: content,
          localPath: localPath,
          voiceDurationSeconds: voiceDurationSeconds,
        );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 280));
        saved = pending.copyWith(
          sendStatus: MessageSendStatus.success,
          messageUid: _store.nextMessageUid(),
        );
        await _store.replaceMessage(ref, saved);
        if (ref.isPrivate) {
          unawaited(
            Future.delayed(const Duration(seconds: 2), () {
              _store.simulatePeerRead(ref, localId);
            }),
          );
        }
      }

      unawaited(
        _backup.backupOutbound(
          imUserId: imUserId,
          conversationId: ref.storageId,
          messageUid: saved.messageUid ?? saved.id,
          type: backupType,
          payload: payload,
          sentAt: saved.createdAt,
        ),
      );
      return saved;
    } catch (e, st) {
      LogUtils.e('[ImChat] send failed', e, st);
      final failed = pending.copyWith(sendStatus: MessageSendStatus.failed);
      await _store.replaceMessage(ref, failed);
      rethrow;
    }
  }

  Future<MessageModel> _sendViaSdk(
    ConversationRef ref, {
    required MessageModel pending,
    required MessageType type,
    required String content,
    String? localPath,
    int voiceDurationSeconds = 0,
  }) async {
    final engine = _engine!;
    final rongType = toRongType(ref.type);
    final sent = switch (type) {
      MessageType.text => await engine.sendText(
          type: rongType,
          targetId: ref.targetId,
          text: content,
        ),
      MessageType.image => await engine.sendImage(
          type: rongType,
          targetId: ref.targetId,
          localPath: localPath ?? content,
        ),
      MessageType.voice => await engine.sendVoice(
          type: rongType,
          targetId: ref.targetId,
          localPath: localPath ?? content,
          durationSeconds: voiceDurationSeconds,
        ),
      _ => throw StateError('unsupported sdk type $type'),
    };
    final mapped = messageFromRong(
      msg: sent,
      conversationId: ref.storageId,
      selfImUserId: _session.currentImUserId,
    ).copyWith(
      id: pending.id,
      sendStatus: MessageSendStatus.success,
    );
    await _store.replaceMessage(ref, mapped);
    return mapped;
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
    final name = profile?.displayName.trim() ?? '';
    final avatar = profile?.avatarUrl.trim() ?? '';
    return _store.ensurePrivateConversation(
      peerImUserId: peerImUserId,
      title: name.isNotEmpty ? name : peerImUserId,
      portraitUrl: avatar.isNotEmpty ? avatar : ChatAvatarUrls.peer(peerImUserId),
    );
  }

  Future<ConversationModel> ensureGroupConversation({
    required String groupId,
    required String title,
  }) async {
    _requireConnected();
    return _store.ensureGroupConversation(
      groupId: groupId,
      title: title,
      portraitUrl: ChatAvatarUrls.peer('g_$groupId'),
    );
  }

  Future<void> _pullConversationsFromSdk() async {
    try {
      final list = await _engine!.fetchConversations();
      final mapped = <ConversationModel>[];
      for (final c in list) {
        final model = conversationFromRong(c);
        if (model.targetId.isEmpty) continue;
        if (model.isPrivate) {
          final profile = await _profileService.getProfile(model.targetId);
          final name = profile?.displayName.trim() ?? '';
          final avatar = profile?.avatarUrl.trim() ?? '';
          mapped.add(
            model.copyWith(
              title: name.isNotEmpty ? name : model.title,
              portraitUrl: avatar.isNotEmpty ? avatar : model.portraitUrl,
            ),
          );
        } else {
          mapped.add(model);
        }
      }
      _store.replaceConversations(mapped);
    } catch (e, st) {
      LogUtils.e('[ImChat] pull conversations failed', e, st);
    }
  }

  Future<void> _pullHistoryFromSdk(ConversationRef ref, {int limit = 20}) async {
    try {
      final list = await _engine!.fetchMessages(
        type: toRongType(ref.type),
        targetId: ref.targetId,
        count: limit,
      );
      final selfId = _session.currentImUserId;
      final mapped = list
          .map(
            (m) => messageFromRong(
              msg: m,
              conversationId: ref.storageId,
              selfImUserId: selfId,
            ),
          )
          .toList();
      // SDK 常按时间倒序；store 也用 insert(0)=最新在前。
      _store.replaceMessages(ref, mapped);
    } catch (e, st) {
      LogUtils.e('[ImChat] pull history failed', e, st);
    }
  }

  void _wireListenerIfNeeded() {
    if (_listenerWired || !_sdk) return;
    _listenerWired = true;
    _engine!.attachMessageListener((msg) {
      final ref = refFromRongMessage(msg);
      if (ref == null) return;
      final mapped = messageFromRong(
        msg: msg,
        conversationId: ref.storageId,
        selfImUserId: _session.currentImUserId,
      );
      unawaited(_store.insertMessage(ref: ref, message: mapped));
      final imUserId = _session.currentImUserId;
      if (imUserId != null && mapped.messageUid != null && !mapped.isSelf) {
        unawaited(
          _backup.backupInbound(
            imUserId: imUserId,
            conversationId: ref.storageId,
            messageUid: mapped.messageUid!,
            type: mapped.type.name,
            payload: {'content': mapped.content},
            sentAt: mapped.createdAt,
          ),
        );
      }
    });
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
    _store.bindSelfImUserId(imUserId, enableSeed: !_sdk);
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
