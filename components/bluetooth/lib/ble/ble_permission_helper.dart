import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// BLE 扫描/连接所需运行时权限。
class BlePermissionHelper {
  BlePermissionHelper._();

  static Future<bool> ensureGranted() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.request();
      final connect = await Permission.bluetoothConnect.request();
      // 部分 Android 机型扫描仍依赖定位权限。
      final location = await Permission.locationWhenInUse.request();
      return scan.isGranted &&
          connect.isGranted &&
          (location.isGranted || location.isLimited);
    }

    // iOS：Info.plist 声明后，首次扫描/连接会弹系统授权。
    return true;
  }
}
