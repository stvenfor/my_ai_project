import 'package:module_core/model/im/conversation_type.dart';

/// 单聊 / 群聊统一引用（targetId 为 imUserId 或 groupId）。
class ConversationRef {
  const ConversationRef._({
    required this.type,
    required this.targetId,
  });

  factory ConversationRef.private(String imUserId) {
    return ConversationRef._(
      type: ConversationType.private,
      targetId: imUserId,
    );
  }

  factory ConversationRef.group(String groupId) {
    return ConversationRef._(
      type: ConversationType.group,
      targetId: groupId,
    );
  }

  factory ConversationRef.parse({
    required String type,
    required String targetId,
  }) {
    return ConversationRef._(
      type: type == 'group' ? ConversationType.group : ConversationType.private,
      targetId: targetId,
    );
  }

  final ConversationType type;
  final String targetId;

  bool get isPrivate => type == ConversationType.private;

  bool get isGroup => type == ConversationType.group;

  String get storageId => isPrivate ? 'private_$targetId' : 'group_$targetId';

  @override
  bool operator ==(Object other) {
    return other is ConversationRef &&
        other.type == type &&
        other.targetId == targetId;
  }

  @override
  int get hashCode => Object.hash(type, targetId);
}
