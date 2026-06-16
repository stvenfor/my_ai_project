class ConversationModel {
  ConversationModel({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isOnline = false,
    this.unreadCount = 0,
  });

  final String id;
  final String peerId;
  final String peerName;
  final String peerAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isOnline;
  final int unreadCount;

  ConversationModel copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? peerAvatar,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isOnline,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
