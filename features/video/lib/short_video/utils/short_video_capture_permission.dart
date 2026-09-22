import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

/// 小视频拍摄前的相机/麦克风权限引导。
abstract final class ShortVideoCapturePermission {
  ShortVideoCapturePermission._();

  /// 主动申请权限；成功返回 true。永久拒绝则弹窗引导去设置。
  static Future<bool> ensureForCameraCapture({
    bool withMicrophone = true,
  }) async {
    final result = await ImagePickerUtils.requestCameraAccess(
      withMicrophone: withMicrophone,
    );
    switch (result) {
      case MediaPermissionResult.granted:
        return true;
      case MediaPermissionResult.denied:
        UiKitInitializer.toastError('需要相机权限才能拍摄，请允许后重试');
        return false;
      case MediaPermissionResult.permanentlyDenied:
        final go = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('需要相机权限'),
            content: Text(
              withMicrophone
                  ? '相机或麦克风权限已被关闭。请在系统设置中开启后，再回来拍摄。'
                  : '相机权限已被关闭。请在系统设置中开启后，再回来拍摄。',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('去设置'),
              ),
            ],
          ),
        );
        if (go == true) {
          await ImagePickerUtils.openPermissionSettings();
        }
        return false;
    }
  }
}
