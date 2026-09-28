import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:module_http/http/backend_http_config.dart';

/// Go BFF gRPC 地址解析（与 HTTP 同源 host，默认端口 9090）。
class BackendGrpcConfig {
  BackendGrpcConfig._();

  static const int defaultPort = 9090;

  static const String backendGrpcPortOverride = String.fromEnvironment(
    'BACKEND_GRPC_PORT',
  );

  static int get port {
    final raw = backendGrpcPortOverride.trim();
    if (raw.isEmpty) return defaultPort;
    return int.tryParse(raw) ?? defaultPort;
  }

  /// 解析 gRPC host（不含 scheme）。
  static String resolveHost() {
    final httpBase = BackendHttpConfig.resolveBackendBaseUrl();
    final uri = Uri.tryParse(httpBase);
    if (uri != null && uri.host.isNotEmpty) {
      return uri.host;
    }
    final lan = BackendHttpConfig.effectiveBackendHost;
    if (lan.isNotEmpty) return lan;
    if (!kIsWeb) {
      try {
        // 仅模拟器需要 10.0.2.2；真机上它无意义（且真机必须注入 BACKEND_HOST）。
        if (Platform.isAndroid && !BackendHttpConfig.isPhysicalDevice) {
          return '10.0.2.2';
        }
      } catch (_) {}
    }
    return '127.0.0.1';
  }
}
