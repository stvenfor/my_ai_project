/// 聊天模块 Mock 头像（picsum 按 seed 固定，避免 pravatar 403）。
class ChatAvatarUrls {
  ChatAvatarUrls._();

  static const self = 'https://picsum.photos/seed/chat_self/150/150';

  static String peer(String peerId) =>
      'https://picsum.photos/seed/chat_$peerId/150/150';
}
