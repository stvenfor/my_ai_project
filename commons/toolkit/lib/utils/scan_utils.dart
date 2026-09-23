import 'package:flutter/material.dart';
import 'package:module_utils/utils/image_picker_utils.dart';
import 'package:module_utils/widgets/scan_page.dart';
import 'package:scan/scan.dart';

export 'package:module_utils/widgets/scan_page.dart' show ScanOptions, ScanPage;

/// 二维码/条形码公用工具（基于 [scan] 插件）。
abstract final class ScanUtils {
  ScanUtils._();

  /// 相机权限（与 [ImagePickerUtils] 一致）。
  static Future<bool> ensureCameraPermission() =>
      ImagePickerUtils.ensureCameraPermission();

  /// 打开全屏扫码页，成功返回内容；取消或无权限返回 null。
  ///
  /// 使用 rootNavigator，避免嵌在 Tab / IndexedStack 时 push 进错 Navigator、
  /// 页面看起来「点了没跳转」。
  static Future<String?> scanWithCamera(
    BuildContext context, {
    ScanOptions options = const ScanOptions(),
  }) async {
    final perm = await ImagePickerUtils.requestCameraAccess();
    if (perm != MediaPermissionResult.granted) {
      return null;
    }
    if (!context.mounted) return null;

    final navigator = Navigator.maybeOf(context, rootNavigator: true) ??
        Navigator.maybeOf(context);
    if (navigator == null) return null;

    return navigator.push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ScanPage(options: options),
      ),
    );
  }

  /// 从图片路径解析二维码/条形码。
  static Future<String?> parseFromPath(String path) async {
    if (path.isEmpty) return null;
    final result = await Scan.parse(path);
    if (result == null || result.isEmpty) return null;
    return result;
  }

  /// 相册选图后解析。
  static Future<String?> parseFromGallery({double? maxWidth = 1200}) async {
    final path = await ImagePickerUtils.pickFromGallery(maxWidth: maxWidth);
    if (path == null) return null;
    return parseFromPath(path);
  }
}
