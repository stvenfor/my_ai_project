/// Go BFF 业务码（与 my_go_study `response.Code*` 对齐）。
///
/// 客户端分支只认 code；[message] 仅用于展示。文案匹配仅作旧包兼容兜底。
abstract final class AuthBizCode {
  /// 登录凭证错误（密码错误等）。
  static const unauthorized = 10002;

  /// 账号未注册（Go handler 现用 CodeForbidden=10003 表达此语义）。
  static const accountNotRegistered = 10003;

  static const forbidden = 10003;

  /// 单设备：账号已在其他设备登录。
  static const sessionReplaced = 10021;

  /// 单设备：会话无效（缺 header / Redis 无会话 / 同设备 session 过期等）。
  static const sessionInvalid = 10022;

  /// access token 无效 / 未带 Authorization；先 refresh，失败再清会话。
  static const tokenInvalid = 10023;

  /// 验证码错误或已失效。
  static const invalidOtp = 10024;

  static const internalError = 50000;

  static bool isForceLogout(int? code) =>
      code == sessionReplaced || code == sessionInvalid;

  static bool isSessionReplaced(int? code) => code == sessionReplaced;

  /// token 废或单设备会话废：本地会话应视为已失效。
  static bool isSessionGone(int? code) =>
      isForceLogout(code) || code == tokenInvalid;

  /// 可尝试静默 refresh（非互踢、非纯密码错）。
  static bool isTryRefresh(int? code) => code == tokenInvalid;
}
