/// 社区 Mock 头像（pravatar，失败时由 CacheImageUtils 占位）。
class CommunityAvatarUrls {
  CommunityAvatarUrls._();

  static String user(int seed) => 'https://i.pravatar.cc/200?img=$seed';
}
