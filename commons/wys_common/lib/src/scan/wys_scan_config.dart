import 'package:flutter/material.dart';

/// 扫码页配置。
///
/// 底层引擎为 OHOS 适配的 mobile_scanner。
class WysScanConfig {
  const WysScanConfig({
    this.title = '扫一扫',
    this.hint = '将二维码放入框内，即可自动扫码',
    this.borderColor = const Color.fromARGB(255, 255, 20, 147),
    this.scanLineColor = const Color.fromARGB(255, 255, 20, 147),
    this.overlayColor = const Color(0xDD000000),
    this.scanArea,
    this.bottomOffset,
    this.showFlashButton = true,
    this.autoPopOnCapture = true,
    this.requestCameraPermission,
    this.unsupportedMessage = '当前平台暂不支持扫码',
    this.flashOnIcon = Icons.flash_on,
    this.flashOffIcon = Icons.flash_off,
  });

  final String title;
  final String hint;
  final Color borderColor;
  final Color scanLineColor;
  final Color overlayColor;

  /// 识别区域尺寸；为空时按设计稿 280/375 比例。
  final Size? scanArea;

  /// 扫描框相对垂直中心上移量；为空时按设计稿 50 缩放。
  final double? bottomOffset;

  final bool showFlashButton;
  final bool autoPopOnCapture;

  /// 返回 true 表示已获得相机权限，可继续打开扫码页。
  final Future<bool> Function()? requestCameraPermission;

  /// 平台不支持扫码时的提示文案。
  final String unsupportedMessage;

  /// 闪光灯开启图标（Material，替代迁入 png）。
  final IconData flashOnIcon;

  /// 闪光灯关闭图标（Material，替代迁入 png）。
  final IconData flashOffIcon;

  Size resolveScanArea(BuildContext context) {
    if (scanArea != null) return scanArea!;
    final width = MediaQuery.sizeOf(context).width;
    final side = width * (280 / 375);
    return Size(side, side);
  }

  double resolveBottomOffset(BuildContext context) {
    if (bottomOffset != null) return bottomOffset!;
    return MediaQuery.sizeOf(context).width * (50 / 375);
  }

  /// 扫描框切孔：垂直居中后上移 [bottomOffset]。
  Rect resolveScanWindow(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final area = resolveScanArea(context);
    final offset = resolveBottomOffset(context);
    final left = (size.width - area.width) / 2;
    final top = (size.height - area.height) / 2 - offset;
    return Rect.fromLTWH(left, top, area.width, area.height);
  }
}
