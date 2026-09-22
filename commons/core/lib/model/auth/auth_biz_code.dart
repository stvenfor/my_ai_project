/// Go BFF 业务码（与 my_go_study `response.Code*` 对齐）。
///
/// 客户端分支只认 code；[message] 仅用于展示。
abstract final class AuthBizCode {
  static const unauthorized = 10002;
  static const accountNotRegistered = 10003;

  /// 单设备：账号已在其他设备登录。
  static const sessionReplaced = 10021;

  /// 单设备：会话无效（缺 header / Redis 无会话 / 同设备 session 过期等）。
  static const sessionInvalid = 10022;

  static const internalError = 50000;

  static bool isForceLogout(int? code) =>
      code == sessionReplaced || code == sessionInvalid;

  static bool isSessionReplaced(int? code) => code == sessionReplaced;
}
