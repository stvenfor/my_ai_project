import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_http/http/http.dart';

/// 从 [UserService] 读取 Supabase access token，注入 Authorization 头。
class AuthHeaderProvider implements HttpHeaderProvider {
  const AuthHeaderProvider();

  @override
  Map<String, dynamic> getHeaders(RequestOptions options) {
    final user = Get.isRegistered<UserService>()
        ? Get.find<UserService>().currentUser.value
        : null;
    final token = user?.token;
    final headers = <String, dynamic>{
      Headers.acceptHeader: Headers.jsonContentType,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final sessionId = user?.sessionId;
    final deviceId = user?.deviceId;
    if (sessionId != null && sessionId.isNotEmpty) {
      headers['X-Session-ID'] = sessionId;
    }
    if (deviceId != null && deviceId.isNotEmpty) {
      headers['X-Device-ID'] = deviceId;
    }
    return headers;
  }
}
