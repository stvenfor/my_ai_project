import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:module_core/core.dart';

/// 解析 my_go_study Go 后端 baseUrl。
class BackendHttpConfig {
  BackendHttpConfig._();

  /// 真机调试：`flutter run --dart-define=BACKEND_HOST=192.168.x.x`
  static const String backendHostOverride = String.fromEnvironment(
    'BACKEND_HOST',
  );

  static String resolveBackendBaseUrl() {
    final configured = _readConfiguredBaseUrl();
    return remapLocalhostForPlatform(configured);
  }

  static String _readConfiguredBaseUrl() {
    if (Get.isRegistered<EnvironmentService>()) {
      return Get.find<EnvironmentService>().backendBaseUrl;
    }
    return EnvConfig.of(AppEnv.test).backendBaseUrl;
  }

  /// Android 模拟器：127.0.0.1 → 10.0.2.2。
  /// 鸿蒙/iOS 真机：用 [BACKEND_HOST]（局域网 IP），勿映射到 10.0.2.2。
  static String remapLocalhostForPlatform(String baseUrl) {
    if (kIsWeb) return baseUrl;
    try {
      final uri = Uri.tryParse(baseUrl);
      if (uri == null) return baseUrl;
      final host = uri.host;
      if (host != '127.0.0.1' && host != 'localhost') return baseUrl;

      if (backendHostOverride.isNotEmpty) {
        return uri.replace(host: backendHostOverride).toString();
      }
      if (_isAndroidEmulatorStyleHost) {
        return uri.replace(host: '10.0.2.2').toString();
      }
    } catch (_) {
      // 非 VM 平台（如部分测试环境）忽略。
    }
    return baseUrl;
  }

  /// 仅 Android 需要模拟器 localhost 映射；鸿蒙真机不是模拟器。
  static bool get _isAndroidEmulatorStyleHost {
    if (Platform.isAndroid) return true;
    return false;
  }
}
