import 'package:module_chat/chat/models/chat_avatar_urls.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_core/model/im/conversation_ref.dart';
import 'package:module_core/model/im/conversation_type.dart';
import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

RCIMIWConversationType toRongType(ConversationType type) {
  return type == ConversationType.group
      ? RCIMIWConversationType.group
      : RCIMIWConversationType.private;
}

ConversationRef? refFromRongMessage(RCIMIWMessage msg) {
  final targetId = msg.targetId;
  if (targetId == null || targetId.isEmpty) return null;
  if (msg.conversationType == RCIMIWConversationType.group) {
    return ConversationRef.group(targetId);
  }
  if (msg.conversationType == RCIMIWConversationType.private) {
    return ConversationRef.private(targetId);
  }
  return null;
}

ConversationModel conversationFromRong(RCIMIWConversation c) {
  final targetId = c.targetId ?? '';
  final isGroup = c.conversationType == RCIMIWConversationType.group;
  final last = c.lastMessage;
  final preview = last == null ? '' : previewFromRong(last);
  final tsMs = last?.sentTime ?? c.operationTime ?? 0;
  final time = tsMs > 0
      ? DateTime.fromMillisecondsSinceEpoch(tsMs)
      : DateTime.fromMillisecondsSinceEpoch(0);
  if (isGroup) {
    return ConversationModel.group(
      targetId: targetId,
      title: targetId,
      portraitUrl: ChatAvatarUrls.peer('g_$targetId'),
      lastMessage: preview,
      lastMessageTime: time,
      unreadCount: c.unreadCount ?? 0,
    );
  }
  return ConversationModel.private(
    targetId: targetId,
    title: targetId,
    portraitUrl: ChatAvatarUrls.peer(targetId),
    lastMessage: preview,
    lastMessageTime: time,
    unreadCount: c.unreadCount ?? 0,
  );
}

String previewFromRong(RCIMIWMessage msg) {
  if (msg is RCIMIWTextMessage) return msg.text ?? '';
  if (msg is RCIMIWImageMessage) return '[图片]';
  if (msg is RCIMIWVoiceMessage) return '[语音]';
  return '[消息]';
}

MessageModel messageFromRong({
  required RCIMIWMessage msg,
  required String conversationId,
  required String? selfImUserId,
}) {
  final sender = msg.senderUserId ?? '';
  final isSelf = msg.direction == RCIMIWMessageDirection.send ||
      (selfImUserId != null && sender == selfImUserId);
  final ts = msg.sentTime ?? DateTime.now().millisecondsSinceEpoch;
  final id = msg.messageUId ??
      msg.messageId?.toString() ??
      'm_${ts}_${sender.hashCode}';

  if (msg is RCIMIWTextMessage) {
    return MessageModel(
      id: id,
      messageUid: msg.messageUId,
      conversationId: conversationId,
      type: MessageType.text,
      content: msg.text ?? '',
      isSelf: isSelf,
      senderImUserId: sender.isEmpty ? null : sender,
      createdAt: DateTime.fromMillisecondsSinceEpoch(ts),
      sendStatus: MessageSendStatus.success,
      readStatus: isSelf ? MessageReadStatus.read : MessageReadStatus.unread,
    );
  }
  if (msg is RCIMIWImageMessage) {
    final path = msg.local ?? msg.remote ?? '';
    return MessageModel(
      id: id,
      messageUid: msg.messageUId,
      conversationId: conversationId,
      type: MessageType.image,
      content: path,
      isSelf: isSelf,
      senderImUserId: sender.isEmpty ? null : sender,
      createdAt: DateTime.fromMillisecondsSinceEpoch(ts),
      sendStatus: MessageSendStatus.success,
      readStatus: isSelf ? MessageReadStatus.read : MessageReadStatus.unread,
      localPath: msg.local,
      remoteUrl: msg.remote,
    );
  }
  if (msg is RCIMIWVoiceMessage) {
    final path = msg.local ?? msg.remote ?? '';
    return MessageModel(
      id: id,
      messageUid: msg.messageUId,
      conversationId: conversationId,
      type: MessageType.voice,
      content: path,
      isSelf: isSelf,
      senderImUserId: sender.isEmpty ? null : sender,
      createdAt: DateTime.fromMillisecondsSinceEpoch(ts),
      sendStatus: MessageSendStatus.success,
      readStatus: isSelf ? MessageReadStatus.read : MessageReadStatus.unread,
      voiceDurationSeconds: msg.duration ?? 0,
      localPath: msg.local,
      remoteUrl: msg.remote,
    );
  }
  return MessageModel(
    id: id,
    messageUid: msg.messageUId,
    conversationId: conversationId,
    type: MessageType.system,
    content: previewFromRong(msg),
    isSelf: isSelf,
    senderImUserId: sender.isEmpty ? null : sender,
    createdAt: DateTime.fromMillisecondsSinceEpoch(ts),
  );
}
