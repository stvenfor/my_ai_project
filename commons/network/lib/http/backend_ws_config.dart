import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// 解析 WebSocket 连接地址（与 [BackendHttpConfig] 相同的 localhost 映射策略）。
class BackendWsConfig {
  BackendWsConfig._();

  /// 模拟器无法访问宿主机 127.0.0.1，Android / 鸿蒙需映射为 10.0.2.2。
  static String resolveWsUrl(String wsUrl) {
    if (kIsWeb) return wsUrl;
    try {
      if (!_needsEmulatorHostRemap) return wsUrl;
      final uri = Uri.tryParse(wsUrl);
      if (uri == null) return wsUrl;
      final host = uri.host;
      if (host == '127.0.0.1' || host == 'localhost') {
        return uri.replace(host: '10.0.2.2').toString();
      }
    } catch (_) {
      // 非 VM 平台忽略。
    }
    return wsUrl;
  }

  static bool get _needsEmulatorHostRemap {
    if (Platform.isAndroid) return true;
    return Platform.operatingSystem.toLowerCase() == 'ohos';
  }
}
