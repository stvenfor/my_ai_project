import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/session/session_recovery.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/http/http.dart';
import 'package:module_http/http/rsp_interceptor.dart';
import 'package:module_route/route/route_path.dart';

/// 全局 HTTP 401 会话失效处理（单设备登录被动踢下线）。
class SessionGuardHook implements HttpResponseHook {
  static bool _handling = false;

  @override
  void onResponse(Response<dynamic> response) {
    final message = extractMessage(response.data);
    if (!shouldForceLogout(message)) return;
    unawaited(_handleForcedLogout(message));
  }

  @override
  void onError(DioException error) {
    final message = extractMessage(error.response?.data);
    if (message.isEmpty) {
      final fallback = error.message?.trim();
      if (fallback != null &&
          fallback.isNotEmpty &&
          shouldForceLogout(fallback)) {
        unawaited(_handleForcedLogout(fallback));
      }
      return;
    }
    if (!shouldForceLogout(message)) return;
    unawaited(_handleForcedLogout(message));
  }

  static bool shouldForceLogout(String message) {
    if (message.contains('其他设备登录')) return true;
    if (message.contains('会话无效')) return true;
    return false;
  }

  static bool isForceLogoutError(Object error) {
    if (error is HttpRequestException) {
      return shouldForceLogout(error.message);
    }
    return shouldForceLogout(error.toString());
  }

  /// 供 Realtime 等模块在 HTTP Hook 未触发时兜底踢下线。
  static Future<void> handleIfForceLogout(Object error) async {
    if (!isForceLogoutError(error)) return;
    final message = error is HttpRequestException
        ? error.message
        : error.toString();
    await _handleForcedLogout(message);
  }

  /// access token 过期时可尝试 refresh（与互踢/会话失效区分）。
  static bool shouldTryTokenRefresh(String message) {
    if (shouldForceLogout(message)) return false;
    if (message.contains('token 无效')) return true;
    if (message.contains('JWT') || message.contains('jwt')) return true;
    if (message.contains('token expired') ||
        message.contains('Token expired')) {
      return true;
    }
    return false;
  }

  static String extractMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) return error;
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return data?.toString() ?? '';
  }

  static Future<void> _handleForcedLogout(String message) async {
    if (_handling) return;
    _handling = true;
    try {
      final recovered = await SessionRecovery.tryRecover();
      if (recovered) {
        return;
      }
      final text = message.contains('其他设备登录')
          ? '账号已在其他设备登录，请重新登录'
          : '登录已失效，请重新登录';
      UiKitInitializer.toast(text);
      await AuthSession.logout();
      if (Get.currentRoute != RoutePath.login) {
        Get.offAllNamed(RoutePath.login);
      }
    } finally {
      _handling = false;
    }
  }
}
