import 'package:module_core/model/auth/auth_biz_code.dart';

/// HTTP 鉴权决策（统一入口，避免各业务自行猜 401/403）。
///
/// | 类别 | 典型条件 | 行为 |
/// |------|----------|------|
/// | [forceLogout] | 业务码 10021/10022 | 弹窗 → 清会话 → 登录页 |
/// | [tryRefresh] | 10023 / HTTP 401（非互踢） | 静默续期，失败再 forceLogout |
/// | [forbidden] | HTTP 403 | **不**登出，业务自行提示无权限 |
/// | [none] | 其它 | 不管会话 |
///
/// 分支优先 [code]；[message] 仅旧包无 code 时兜底。
enum AuthHttpDecision { forceLogout, tryRefresh, forbidden, none }

/// 统一分类。业务码优先于 HTTP status / 文案。
AuthHttpDecision classifyAuthHttp({
  int? statusCode,
  int? code,
  String message = '',
}) {
  if (AuthBizCode.isForceLogout(code) ||
      (code == null &&
          (message.contains('其他设备登录') || message.contains('会话无效')))) {
    return AuthHttpDecision.forceLogout;
  }
  // 仅 HTTP 403：勿用 code==10003（与「账号未注册」共用）。
  if (statusCode == 403) {
    return AuthHttpDecision.forbidden;
  }
  if (AuthBizCode.isTryRefresh(code) ||
      statusCode == 401 ||
      (code == null && _looksLikeExpiredToken(message))) {
    return AuthHttpDecision.tryRefresh;
  }
  return AuthHttpDecision.none;
}

/// 旧包无 code 时的文案兜底；新路径勿再依赖。
bool _looksLikeExpiredToken(String message) {
  return message.contains('token 无效') ||
      message.contains('token 已过期') ||
      message.contains('JWT') ||
      message.contains('jwt') ||
      message.contains('token expired') ||
      message.contains('Token expired') ||
      message.contains('未提供 Authorization') ||
      message.contains('未授权');
}

/// Realtime / hydrate 等：鉴权硬失败应停重试；403 不在此列。
bool isAuthHttpHardFailure({
  int? statusCode,
  int? code,
  String message = '',
}) {
  final d = classifyAuthHttp(
    statusCode: statusCode,
    code: code,
    message: message,
  );
  return d == AuthHttpDecision.forceLogout || d == AuthHttpDecision.tryRefresh;
}
