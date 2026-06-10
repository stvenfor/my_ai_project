import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// 设备信息工具。
class DeviceInfoUtils {
  DeviceInfoUtils._();

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

  static Map<String, dynamic> _webInfoToMap(WebBrowserInfo info) {
    return {
      'browserName': info.browserName.name,
      'userAgent': info.userAgent,
      'platform': info.platform,
      'vendor': info.vendor,
    };
  }
}
