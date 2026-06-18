import 'package:module_core/model/im/conversation_ref.dart';
import 'package:module_core/model/im/conversation_type.dart';

class ConversationModel {
  ConversationModel({
    required this.id,
    required this.type,
    required this.targetId,
    required this.title,
    required this.portraitUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isOnline = false,
    this.unreadCount = 0,
    this.memberCount = 0,
  });

  final String id;
  final ConversationType type;
  final String targetId;
  final String title;
  final String portraitUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;
  final int unreadCount;
  final int memberCount;

  bool get isPrivate => type == ConversationType.private;

  bool get isGroup => type == ConversationType.group;

  /// 兼容旧 UI 字段。
  String get peerId => isPrivate ? targetId : id;

  String get peerName => title;

  String get peerAvatar => portraitUrl;

  ConversationRef get ref => isPrivate
      ? ConversationRef.private(targetId)
      : ConversationRef.group(targetId);

  ConversationModel copyWith({
    String? id,
    ConversationType? type,
    String? targetId,
    String? title,
    String? portraitUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isOnline,
    int? unreadCount,
    int? memberCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      title: title ?? this.title,
      portraitUrl: portraitUrl ?? this.portraitUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  factory ConversationModel.private({
    required String targetId,
    required String title,
    required String portraitUrl,
    required String lastMessage,
    required DateTime lastMessageTime,
    bool isOnline = false,
    int unreadCount = 0,
  }) {
    return ConversationModel(
      id: ConversationRef.private(targetId).storageId,
      type: ConversationType.private,
      targetId: targetId,
      title: title,
      portraitUrl: portraitUrl,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      isOnline: isOnline,
      unreadCount: unreadCount,
    );
  }
}
