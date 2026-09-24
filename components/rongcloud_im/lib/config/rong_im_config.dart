/// 融云 IM 配置。
class RongImConfig {
  RongImConfig._();

  /// App Key 含 PLACEHOLDER、或 `--dart-define=USE_MOCK_IM=true` 时走 Mock。
  static bool useMockImFor(String? appKey) {
    const forceMock = bool.fromEnvironment('USE_MOCK_IM', defaultValue: false);
    if (forceMock) return true;
    final key = (appKey ?? '').trim();
    return key.isEmpty || key.toUpperCase().contains('PLACEHOLDER');
  }

  /// 无 env 时仅看 dart-define / 默认 Mock。
  static bool get useMockIm => useMockImFor(
        const String.fromEnvironment('RONG_APP_KEY', defaultValue: ''),
      );

  static const sessionPath = '/api/v1/im/session';
  static const profilePath = '/api/v1/im/users/profile';
  static const backupPath = '/api/v1/im/messages/backup';
  static const friendsPath = '/api/v1/im/friends';
  static const friendRequestsPath = '/api/v1/im/friends/requests';
  static const usersSearchPath = '/api/v1/im/users/search';
  static const privateAdmissionPath = '/api/v1/im/private/admission';
  static const freeGroupPath = '/api/v1/im/groups/free';
  static const storeGroupSyncPath = '/api/v1/im/groups/store/sync';

  static const connectTimeoutSeconds = 15;
  static const profileCacheTtl = Duration(hours: 24);
}
