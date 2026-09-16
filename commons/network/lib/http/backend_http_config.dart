import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:module_core/core.dart';
import 'package:module_http/http/lan_host.dart';

/// 解析 my_go_study Go 后端 baseUrl。
class BackendHttpConfig {
  BackendHttpConfig._();

  /// `flutter run --dart-define=BACKEND_HOST=` 或 `--dart-define-from-file=.env.lan`
  static const String backendHostOverride = String.fromEnvironment(
    'BACKEND_HOST',
  );

  /// dart-define 优先；未注入时用 [LanHost.fallback]（真机 Run / Release 与 Debug 一致）。
  /// 当前回退：`172.16.0.43`（见 `commons/network/lib/http/lan_host.dart`）。
  static String get effectiveBackendHost {
    if (backendHostOverride.isNotEmpty) return backendHostOverride;
    if (LanHost.fallback.isNotEmpty) return LanHost.fallback;
    return '';
  }

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
  /// 真机 / 未注入 dart-define：用 [effectiveBackendHost]。
  static String remapLocalhostForPlatform(String baseUrl) {
    if (kIsWeb) return baseUrl;
    try {
      final uri = Uri.tryParse(baseUrl);
      if (uri == null) return baseUrl;
      final host = uri.host;
      if (host != '127.0.0.1' && host != 'localhost') return baseUrl;

      final lanHost = effectiveBackendHost;
      if (lanHost.isNotEmpty) {
        return uri.replace(host: lanHost).toString();
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
