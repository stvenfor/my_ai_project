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
    this.sendStatus = MessageSendStatus.success,
    this.readStatus = MessageReadStatus.read,
    this.isRecalled = false,
    this.voiceDurationSeconds = 0,
  });

  final String id;
  final String conversationId;
  final MessageType type;
  final String content;
  final bool isSelf;
  final DateTime createdAt;
  final MessageSendStatus sendStatus;
  final MessageReadStatus readStatus;
  final bool isRecalled;
  final int voiceDurationSeconds;

  MessageModel copyWith({
    String? id,
    String? conversationId,
    MessageType? type,
    String? content,
    bool? isSelf,
    DateTime? createdAt,
    MessageSendStatus? sendStatus,
    MessageReadStatus? readStatus,
    bool? isRecalled,
    int? voiceDurationSeconds,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      content: content ?? this.content,
      isSelf: isSelf ?? this.isSelf,
      createdAt: createdAt ?? this.createdAt,
      sendStatus: sendStatus ?? this.sendStatus,
      readStatus: readStatus ?? this.readStatus,
      isRecalled: isRecalled ?? this.isRecalled,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
    );
  }

  bool get canRecall {
    if (!isSelf || isRecalled || type == MessageType.time || type == MessageType.system) {
      return false;
    }
    return DateTime.now().difference(createdAt).inSeconds <= 180;
  }
}
