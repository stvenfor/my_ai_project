/// 与 iOS `TFErrorCode.m` / 旧 Flutter `HttpUtil.successCode` 对齐。
abstract final class NetworkCodes {
  static const int notNetwork = 0;
  static const int ok = 200;
  static const int invalidAuth = 100;
  static const int invalidMember = 301;
  static const int expireToken = 401;
  static const int busy = 429;
  static const int invalidAccount = 500;

  /// 业务 body `code == -1` 时直接透传原始 JSON（iOS dealWithresponseObject）
  static const int passthrough = -1;
}