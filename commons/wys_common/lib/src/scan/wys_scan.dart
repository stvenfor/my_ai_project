import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../wys_toast.dart';
import 'wys_scan_config.dart';
import 'wys_scan_page.dart';

/// 公用扫码工具。
///
/// 实现参考鸿蒙适配示例
/// [flutter_scan](https://gitcode.com/gcw_jOhhwlE7/flutter_scan)，
/// 底层使用 OpenHarmony 适配的 [mobile_scanner]（Android / iOS / OHOS）。
abstract final class WysScan {
  WysScan._();

  /// Android / iOS / OHOS 支持实时扫码。
  static bool get isSupported {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        // 兼容 OHOS Flutter SDK 的 TargetPlatform.ohos（标准 SDK 无该枚举）。
        return defaultTargetPlatform.name == 'ohos';
    }
  }

  /// 打开全屏扫码页，成功返回码值；取消、无权限或不支持时返回 null。
  static Future<String?> scan(
    BuildContext context, {
    WysScanConfig config = const WysScanConfig(),
  }) async {
    if (!isSupported) {
      WysToast.show(config.unsupportedMessage);
      return null;
    }

    final requestPermission = config.requestCameraPermission;
    if (requestPermission != null) {
      try {
        final granted = await requestPermission();
        // 未授权时由业务侧（如绑定页）自行弹确认框；此处不再额外 Toast。
        if (!granted) return null;
      } catch (_) {
        // 权限回调异常时不打开扫码页，避免无权限静默进相机页。
        return null;
      }
    }

    if (!context.mounted) {
      WysToast.show('页面已关闭，请重试');
      return null;
    }

    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    if (navigator == null) {
      WysToast.show('无法打开扫码页');
      return null;
    }

    return navigator.push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WysScanPage(config: config),
      ),
    );
  }

  /// 从本地图片路径解析二维码/条码。
  static Future<String?> parseImage(String imagePath) async {
    if (imagePath.isEmpty) return null;
    final controller = MobileScannerController();
    try {
      final capture = await controller.analyzeImage(imagePath);
      final codes = capture?.barcodes;
      if (codes == null || codes.isEmpty) return null;
      final value = codes.first.rawValue?.trim();
      if (value == null || value.isEmpty) return null;
      return value;
    } catch (_) {
      return null;
    } finally {
      await controller.dispose();
    }
  }
}
