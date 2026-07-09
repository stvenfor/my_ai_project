import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_http/http/rsp_interceptor.dart';
import 'package:module_route/route/route_path.dart';

/// 全局 HTTP 401 会话失效处理（单设备登录被动踢下线）。
class SessionGuardHook implements HttpResponseHook {
  static bool _handling = false;

  @override
  void onResponse(Response<dynamic> response) {
    if (response.statusCode != 401) return;
    final message = _extractMessage(response.data);
    if (!_shouldForceLogout(message)) return;
    unawaited(_handleForcedLogout(message));
  }

  @override
  void onError(DioException error) {
    if (error.response?.statusCode != 401) return;
    final message = _extractMessage(error.response?.data);
    if (!_shouldForceLogout(message)) return;
    unawaited(_handleForcedLogout(message));
  }

  static bool _shouldForceLogout(String message) {
    if (message.contains('其他设备登录')) return true;
    if (message.contains('会话无效')) return true;
    return false;
  }

  static String _extractMessage(Object? data) {
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
