import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:module_auth/navigation/auth_navigation.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_http/http/http.dart';
import 'package:module_http/http/rsp_interceptor.dart';

/// 全局 HTTP 会话守卫。
///
/// 分类见 [classifyAuthHttp]（module_core）：
/// - **401**：先 refresh（[AuthTokenRefreshInterceptor]），失败再强制登出。
/// - **403**：权限问题，不走登出。
/// - **10021/10022**：立即强制登出（互踢 / 会话无效）。
class SessionGuardHook implements HttpResponseHook {
  static bool _handling = false;

  @override
  void onResponse(Response<dynamic> response) {
    final code = extractCode(response.data);
    final message = extractMessage(response.data);
    final decision = classifyAuthHttp(
      statusCode: response.statusCode,
      code: code,
      message: message,
    );
    if (decision == AuthHttpDecision.forceLogout) {
      unawaited(_handleForcedLogout(code: code, message: message));
    }
  }

  @override
  void onError(DioException error) {
    final data = error.response?.data;
    final code = extractCode(data) ??
        int.tryParse(
          (error.error is HttpRequestException)
              ? ((error.error as HttpRequestException).code ?? '')
              : '',
        );
    var message = extractMessage(data);
    if (message.isEmpty) {
      message = error.message?.trim() ?? '';
    }
    final statusCode = error.response?.statusCode ??
        (error.error is HttpRequestException
            ? (error.error as HttpRequestException).statusCode
            : null);

    final decision = classifyAuthHttp(
      statusCode: statusCode,
      code: code,
      message: message,
    );
    // 401 tryRefresh 由 AuthTokenRefreshInterceptor 处理；此处只接立即踢下线。
    if (decision == AuthHttpDecision.forceLogout) {
      unawaited(_handleForcedLogout(code: code, message: message));
    }
  }

  static AuthHttpDecision classify({
    int? statusCode,
    int? code,
    String message = '',
  }) =>
      classifyAuthHttp(statusCode: statusCode, code: code, message: message);

  static bool shouldForceLogout({
    int? statusCode,
    int? code,
    String message = '',
  }) {
    return classify(statusCode: statusCode, code: code, message: message) ==
        AuthHttpDecision.forceLogout;
  }

  static bool isForceLogoutError(Object error) {
    if (error is SessionReplacedFailure || error is SessionInvalidFailure) {
      return true;
    }
    if (error is HttpRequestException) {
      return classify(
            statusCode: error.statusCode,
            code: int.tryParse(error.code ?? ''),
            message: error.message,
          ) ==
          AuthHttpDecision.forceLogout;
    }
    return shouldForceLogout(message: error.toString());
  }

  /// 供 Realtime 等：鉴权失败（含 401）应停止重连；403 不在此列。
  static bool isAuthHardFailure(Object error) {
    if (isForceLogoutError(error)) return true;
    if (error is HttpRequestException) {
      return isAuthHttpHardFailure(
        statusCode: error.statusCode,
        code: int.tryParse(error.code ?? ''),
        message: error.message,
      );
    }
    if (error is StateError) {
      final m = error.toString();
      return m.contains('token') || m.contains('未登录');
    }
    return isAuthHttpHardFailure(message: error.toString());
  }

  /// 供 Realtime 等模块在 HTTP Hook 未触发时兜底踢下线。
  static Future<void> handleIfForceLogout(Object error) async {
    if (!isForceLogoutError(error)) return;
    final code = error is HttpRequestException
        ? int.tryParse(error.code ?? '')
        : error is SessionReplacedFailure
            ? AuthBizCode.sessionReplaced
            : error is SessionInvalidFailure
                ? AuthBizCode.sessionInvalid
                : null;
    final message = error is HttpRequestException
        ? error.message
        : error is AuthFailure
            ? error.message
            : error.toString();
    await _handleForcedLogout(code: code, message: message);
  }

  /// refresh 失败后的统一收尾：已登出则静默；仍登录则弹窗清会话。
  static Future<void> handleRefreshExhausted({
    int? code,
    String message = '登录已失效，请重新登录',
  }) async {
    if (!AuthLifecycle.isLoggedIn) return;
    await _handleForcedLogout(code: code, message: message);
  }

  /// access token 过期时可尝试 refresh（与互踢/会话失效区分）。
  static bool shouldTryTokenRefresh({
    int? statusCode,
    int? code,
    String message = '',
  }) {
    return classify(statusCode: statusCode, code: code, message: message) ==
        AuthHttpDecision.tryRefresh;
  }

  static int? extractCode(Object? data) {
    if (data is Map) {
      final code = data['code'];
      if (code is int) return code;
      if (code is num) return code.toInt();
      if (code != null) return int.tryParse(code.toString());
    }
    return null;
  }

  static String extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) return error;
    } else if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) return error;
    }
    return data?.toString() ?? '';
  }

  static Future<void> _handleForcedLogout({
    int? code,
    required String message,
  }) async {
    if (_handling) return;
    if (!AuthLifecycle.isLoggedIn) return;
    _handling = true;
    try {
      final kicked = AuthBizCode.isSessionReplaced(code) ||
          message.contains('其他设备登录');
      // 先清本地：否则弹窗等待期间业务请求继续带废 token 刷 401。
      await _clearLocalSession();
      await _showForceLogoutAck(kicked: kicked);
      await AuthNavigation.resetToLogin();
    } finally {
      _handling = false;
    }
  }

  /// 确认弹框；无 overlay 时跳过（仍会清会话回登录）。
  static Future<void> _showForceLogoutAck({required bool kicked}) async {
    for (var i = 0; i < 20; i++) {
      if (Get.overlayContext != null || Get.context != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    if (Get.overlayContext == null && Get.context == null) return;

    await AppDialogManager.I.showAlert(
      title: kicked ? '下线通知' : '登录失效',
      content: kicked
          ? '账号已在其他设备登录，请重新登录'
          : '已退出登录，请重新登录',
      confirmText: '确认',
      showCloseButton: false,
      barrierDismissible: false,
      priority: DialogPriority.high,
    );
  }

  static Future<void> _clearLocalSession() async {
    try {
      // token 已废：勿再调 /user/logout（只会 401）；本地清干净即可。
      await AuthSession.logout(remote: false);
    } catch (_) {
      final userService = AuthLifecycle.maybeUserService;
      if (userService != null) {
        await userService.clearUser();
      }
      await AuthLifecycle.notifyAfterLogout();
    }
  }
}
