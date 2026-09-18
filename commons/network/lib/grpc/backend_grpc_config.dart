import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:module_http/http/backend_http_config.dart';
import 'package:module_http/http/lan_host.dart';

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
        if (Platform.isAndroid) return '10.0.2.2';
      } catch (_) {}
    }
    if (LanHost.fallback.isNotEmpty) return LanHost.fallback;
    return '127.0.0.1';
  }
}
