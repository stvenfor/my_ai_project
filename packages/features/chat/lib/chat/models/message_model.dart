import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';

class MessageModel {
  MessageModel({
    required this.id,
    required this.conversationId,
    required this.type,
    required this.content,
    required this.isSelf,
    required this.createdAt,
    this.messageUid,
    this.senderImUserId,
    this.senderDisplayName,
    this.sendStatus = MessageSendStatus.success,
    this.readStatus = MessageReadStatus.read,
    this.isRecalled = false,
    this.voiceDurationSeconds = 0,
    this.customType,
    this.customPayload = const {},
    this.localPath,
    this.remoteUrl,
  });

  final String id;
  final String conversationId;
  final MessageType type;
  final String content;
  final bool isSelf;
  final DateTime createdAt;
  final String? messageUid;
  final String? senderImUserId;
  final String? senderDisplayName;
  final MessageSendStatus sendStatus;
  final MessageReadStatus readStatus;
  final bool isRecalled;
  final int voiceDurationSeconds;
  final String? customType;
  final Map<String, dynamic> customPayload;
  final String? localPath;
  final String? remoteUrl;

  MessageModel copyWith({
    String? id,
    String? conversationId,
    MessageType? type,
    String? content,
    bool? isSelf,
    DateTime? createdAt,
    String? messageUid,
    String? senderImUserId,
    String? senderDisplayName,
    MessageSendStatus? sendStatus,
    MessageReadStatus? readStatus,
    bool? isRecalled,
    int? voiceDurationSeconds,
    String? customType,
    Map<String, dynamic>? customPayload,
    String? localPath,
    String? remoteUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      content: content ?? this.content,
      isSelf: isSelf ?? this.isSelf,
      createdAt: createdAt ?? this.createdAt,
      messageUid: messageUid ?? this.messageUid,
      senderImUserId: senderImUserId ?? this.senderImUserId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      sendStatus: sendStatus ?? this.sendStatus,
      readStatus: readStatus ?? this.readStatus,
      isRecalled: isRecalled ?? this.isRecalled,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
      customType: customType ?? this.customType,
      customPayload: customPayload ?? this.customPayload,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
    );
  }

  bool get canRecall {
    if (!isSelf || isRecalled || type == MessageType.time || type == MessageType.system) {
      return false;
    }
    return DateTime.now().difference(createdAt).inSeconds <= 180;
  }
}
