import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:module_http/http/backend_http_config.dart';

/// 解析 WebSocket 连接地址（与 [BackendHttpConfig] 相同的 localhost 映射策略）。
class BackendWsConfig {
  BackendWsConfig._();

  /// 与 HTTP 一致：Android 模拟器 → 10.0.2.2；真机用 BACKEND_HOST。
  static String resolveWsUrl(String wsUrl) {
    if (kIsWeb) return wsUrl;
    return BackendHttpConfig.remapLocalhostForPlatform(wsUrl);
  }
}
