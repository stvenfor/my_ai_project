/// 混编：从原生拉取 token / baseUrl（对齐 `ApiService.apiGetUserToken`）。
typedef NativeAuthProvider = Future<NativeSession> Function();

NativeAuthProvider? nativeAuthProvider;

class NativeSession {
  const NativeSession({
    required this.url,
    required this.token,
    this.isStar = false,
    this.subjectId = '',
    this.clientVersion,
    this.clientBuildNumber,
  });

  final String url;
  final String token;
  final bool isStar;
  final String subjectId;
  final String? clientVersion;
  final String? clientBuildNumber;
}