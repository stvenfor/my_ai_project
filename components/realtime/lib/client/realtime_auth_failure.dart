import 'package:module_core/core.dart';
import 'package:module_http/module_http.dart';

/// Realtime 换票/建连鉴权硬失败：再重连只会重复 401。
///
/// 与 [classifyAuthHttp] 对齐：**401 → 硬失败；403 → 非硬失败**。
bool isRealtimeAuthHardFailure(Object error) {
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
