import 'package:module_common_ui/module_common_ui.dart';

/// 小视频拍摄前的相机/麦克风权限引导。
///
/// 实现已收敛到 [CameraPermissionGate]，此处保留薄封装避免改动调用方。
abstract final class ShortVideoCapturePermission {
  ShortVideoCapturePermission._();

  /// 主动申请权限；成功返回 true。永久拒绝则弹窗引导去设置。
  static Future<bool> ensureForCameraCapture({
    bool withMicrophone = true,
  }) {
    return CameraPermissionGate.ensure(
      withMicrophone: withMicrophone,
      deniedToast: '需要相机权限才能拍摄，请在系统弹窗中允许',
      settingsMessage: withMicrophone
          ? '相机或麦克风权限已被关闭。请在系统设置中开启后，再回来拍摄。'
          : '相机权限已被关闭。请在系统设置中开启后，再回来拍摄。',
    );
  }
}
