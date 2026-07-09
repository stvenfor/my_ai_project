import 'package:module_utils/module_utils.dart';

/// 登录/注册时上报给 Go BFF 的设备标识。
class DeviceAuthContext {
  DeviceAuthContext._();

  static Future<DeviceAuthPayload> resolve() async {
    final rawPlatform = (await DeviceInfoUtils.getPlatformName()).toLowerCase();
    final platform = rawPlatform == 'ios' ? 'ios' : 'android';
    final deviceId = await DeviceInfoUtils.getDeviceId();
    return DeviceAuthPayload(
      deviceId: deviceId.isNotEmpty ? deviceId : 'unknown-device',
      platform: platform,
    );
  }
}

class DeviceAuthPayload {
  const DeviceAuthPayload({
    required this.deviceId,
    required this.platform,
  });

  final String deviceId;
  final String platform;
}
