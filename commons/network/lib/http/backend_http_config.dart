import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
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

  /// 是否物理设备（真机）。
  ///
  /// 由壳工程在启动时用 `DeviceInfoUtils.isPhysicalDevice()` 推进来
  /// （module_http 不依赖 module_toolkit，不能在这里直接调）。
  /// 未注入时保守按「模拟器」处理：开发环境（模拟器 / 桌面端）走 loopback，不受影响。
  static bool? _isPhysicalDevice;
  static bool get isPhysicalDevice => _isPhysicalDevice ?? false;
  static void cacheIsPhysicalDevice(bool value) => _isPhysicalDevice = value;

  /// 注入优先。[LanHost.fallback] 恒为空，仅为历史兼容保留。
  static String get effectiveBackendHost {
    if (backendHostOverride.isNotEmpty) return backendHostOverride;
    return LanHost.fallback;
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

  /// 把配置里的 `127.0.0.1` 改写成「当前设备真正能访问到宿主机的地址」：
  ///
  /// | 场景 | 结果 |
  /// |---|---|
  /// | 显式注入 `BACKEND_HOST` | 用它 —— 真机联调的唯一通道 |
  /// | 真机且未注入 | 原样返回 + 告警（真机上 127.0.0.1 指向设备自己） |
  /// | Android 模拟器 | `10.0.2.2`（宿主 loopback 的别名） |
  /// | iOS 模拟器 / macOS 桌面端 | 不改 —— 与后端同机，loopback 直达 |
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

      if (isPhysicalDevice) {
        _warnRealDeviceWithoutOverride();
        return baseUrl;
      }

      if (Platform.isAndroid) {
        return uri.replace(host: '10.0.2.2').toString();
      }
    } catch (_) {
      // 非 VM 平台（如部分测试环境）忽略。
    }
    return baseUrl;
  }

  static bool _warnedRealDeviceWithoutOverride = false;

  static void _warnRealDeviceWithoutOverride() {
    if (_warnedRealDeviceWithoutOverride) return;
    _warnedRealDeviceWithoutOverride = true;
    debugPrint(
      '[BackendHttpConfig] 真机上未注入 BACKEND_HOST：127.0.0.1 指向设备自身，'
      '连不上本机后端。请用 ./scripts/run_app.sh --lan 启动，'
      '或加 --dart-define=BACKEND_HOST=<本机局域网 IP>。',
    );
  }
}
