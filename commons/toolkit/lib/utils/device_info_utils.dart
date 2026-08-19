import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'sp_utils.dart';

/// 设备信息工具。
class DeviceInfoUtils {
  DeviceInfoUtils._();

  static const _stableDeviceIdKey = 'auth_stable_device_id';

  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  /// 获取当前平台设备信息 Map。
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    if (kIsWeb) {
      final info = await _plugin.webBrowserInfo;
      return _webInfoToMap(info);
    }
    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      return _androidInfoToMap(info);
    }
    if (Platform.isIOS) {
      final info = await _plugin.iosInfo;
      return _iosInfoToMap(info);
    }
    if (Platform.isMacOS) {
      final info = await _plugin.macOsInfo;
      return info.data;
    }
    if (Platform.isWindows) {
      final info = await _plugin.windowsInfo;
      return info.data;
    }
    if (Platform.isLinux) {
      final info = await _plugin.linuxInfo;
      return info.data;
    }
    return {'platform': 'unknown'};
  }

  /// 本 App 安装周期内稳定的设备标识（优先读 SP，避免 iOS 模拟器 idfv 为空时反复变化）。
  static Future<String> getStableDeviceId() async {
    final cached = SpUtils.getString(_stableDeviceIdKey);
    if (cached != null &&
        cached.isNotEmpty &&
        !isPlaceholderDeviceId(cached)) {
      return cached;
    }

    var resolved = await getDeviceId();
    if (isPlaceholderDeviceId(resolved)) {
      resolved = _generateInstallId();
    }
    await SpUtils.setString(_stableDeviceIdKey, resolved);
    return resolved;
  }

  static bool isPlaceholderDeviceId(String id) {
    if (id.isEmpty) return true;
    const placeholders = {
      'ios',
      'web',
      'unknown',
      'unknown-device',
    };
    return placeholders.contains(id);
  }

  /// 设备唯一标识（Android ID / iOS identifierForVendor 等）。
  static Future<String> getDeviceId() async {
    if (kIsWeb) {
      final info = await _plugin.webBrowserInfo;
      return info.userAgent ?? 'web';
    }
    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      return info.id;
    }
    if (Platform.isIOS) {
      final info = await _plugin.iosInfo;
      return info.identifierForVendor ?? 'ios';
    }
    final info = await getDeviceInfo();
    return info['deviceId']?.toString() ?? 'unknown';
  }

  /// 是否物理设备（非模拟器/仿真器）。
  static Future<bool> isPhysicalDevice() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      return info.isPhysicalDevice;
    }
    if (Platform.isIOS) {
      final info = await _plugin.iosInfo;
      return info.isPhysicalDevice;
    }
    return true;
  }

  /// 平台名称：android / ios / web / ...
  static Future<String> getPlatformName() async {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static Map<String, dynamic> _androidInfoToMap(AndroidDeviceInfo info) {
    return {
      'deviceId': info.id,
      'brand': info.brand,
      'model': info.model,
      'manufacturer': info.manufacturer,
      'version': info.version.release,
      'sdkInt': info.version.sdkInt,
      'isPhysicalDevice': info.isPhysicalDevice,
    };
  }

  static Map<String, dynamic> _iosInfoToMap(IosDeviceInfo info) {
    return {
      'deviceId': info.identifierForVendor,
      'name': info.name,
      'model': info.model,
      'systemName': info.systemName,
      'systemVersion': info.systemVersion,
      'isPhysicalDevice': info.isPhysicalDevice,
    };
  }

  static String _generateInstallId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static Map<String, dynamic> _webInfoToMap(WebBrowserInfo info) {
    return {
      'browserName': info.browserName.name,
      'userAgent': info.userAgent,
      'platform': info.platform,
      'vendor': info.vendor,
    };
  }
}
