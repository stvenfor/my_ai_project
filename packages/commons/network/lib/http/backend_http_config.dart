import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:module_core/core.dart';

/// 解析 my_go_study Go 后端 baseUrl。
class BackendHttpConfig {
  BackendHttpConfig._();

  static String resolveBackendBaseUrl() {
    final configured = _readConfiguredBaseUrl();
    return _remapLocalhostForPlatform(configured);
  }

  static String _readConfiguredBaseUrl() {
    if (Get.isRegistered<EnvironmentService>()) {
      return Get.find<EnvironmentService>().backendBaseUrl;
    }
    return EnvConfig.of(AppEnv.test).backendBaseUrl;
  }

  /// 模拟器无法访问宿主机 127.0.0.1，Android / 鸿蒙需映射为 10.0.2.2。
  static String _remapLocalhostForPlatform(String baseUrl) {
    if (kIsWeb) return baseUrl;
    try {
      if (!_needsEmulatorHostRemap) return baseUrl;
      final uri = Uri.tryParse(baseUrl);
      if (uri == null) return baseUrl;
      final host = uri.host;
      if (host == '127.0.0.1' || host == 'localhost') {
        return uri.replace(host: '10.0.2.2').toString();
      }
    } catch (_) {
      // 非 VM 平台（如部分测试环境）忽略。
    }
    return baseUrl;
  }

  static bool get _needsEmulatorHostRemap {
    if (Platform.isAndroid) return true;
    return Platform.operatingSystem.toLowerCase() == 'ohos';
  }
}
