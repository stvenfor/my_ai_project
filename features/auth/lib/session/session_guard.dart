import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:module_auth/navigation/auth_navigation.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_http/http/http.dart';
import 'package:module_http/http/rsp_interceptor.dart';

/// 全局 HTTP 401 会话失效处理（单设备登录被动踢下线）。
///
/// 分支依据 Go `{code,message,data}` 的 [AuthBizCode]，不依赖中文文案。
class SessionGuardHook implements HttpResponseHook {
  static bool _handling = false;

  @override
  void onResponse(Response<dynamic> response) {
    final code = extractCode(response.data);
    final message = extractMessage(response.data);
    if (!shouldForceLogout(code: code, message: message)) return;
    unawaited(_handleForcedLogout(code: code, message: message));
  }

  @override
  void onError(DioException error) {
    final data = error.response?.data;
    final code = extractCode(data) ?? int.tryParse(
          (error.error is HttpRequestException)
              ? ((error.error as HttpRequestException).code ?? '')
              : '',
        );
    var message = extractMessage(data);
    if (message.isEmpty) {
      message = error.message?.trim() ?? '';
    }
    if (!shouldForceLogout(code: code, message: message)) return;
    unawaited(_handleForcedLogout(code: code, message: message));
  }

  static bool shouldForceLogout({int? code, String message = ''}) {
    if (AuthBizCode.isForceLogout(code)) return true;
    // gRPC 等仍可能只带文案；HTTP 路径以 code 为准。
    if (message.contains('其他设备登录') || message.contains('会话无效')) {
      return true;
    }
    return false;
  }

  static bool isForceLogoutError(Object error) {
    if (error is SessionReplacedFailure || error is SessionInvalidFailure) {
      return true;
    }
    if (error is HttpRequestException) {
      return shouldForceLogout(
        code: int.tryParse(error.code ?? ''),
        message: error.message,
      );
    }
    return shouldForceLogout(message: error.toString());
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

  /// access token 过期时可尝试 refresh（与互踢/会话失效区分）。
  static bool shouldTryTokenRefresh({int? code, String message = ''}) {
    if (shouldForceLogout(code: code, message: message)) return false;
    if (message.contains('token 无效')) return true;
    if (message.contains('JWT') || message.contains('jwt')) return true;
    if (message.contains('token expired') ||
        message.contains('Token expired')) {
      return true;
    }
    return false;
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
    _handling = true;
    try {
      final kicked = AuthBizCode.isSessionReplaced(code) ||
          message.contains('其他设备登录');
      await _showForceLogoutAck(kicked: kicked);
      await _clearLocalSession();
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
      content: kicked ? '账号已在其他设备登录，请重新登录' : '登录已失效，请重新登录',
      confirmText: '重新登录',
      showCloseButton: false,
      barrierDismissible: false,
      priority: DialogPriority.high,
    );
  }

  static Future<void> _clearLocalSession() async {
    try {
      await AuthSession.logout();
    } catch (_) {
      final userService = AuthLifecycle.maybeUserService;
      if (userService != null) {
        await userService.clearUser();
      }
      await AuthLifecycle.notifyAfterLogout();
    }
  }
}
