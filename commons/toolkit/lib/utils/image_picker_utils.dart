import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum MediaPickSource { gallery, camera }

/// 权限申请结果。
enum MediaPermissionResult {
  /// 已授权（含 Limited）。
  granted,

  /// 本次系统弹窗被拒绝（仍可再次申请）。
  denied,

  /// 永久拒绝 / 受限：系统不再弹窗，需去设置开启。
  permanentlyDenied,
}

class ImagePickerUtils {
  ImagePickerUtils._();

  static final ImagePicker _picker = ImagePicker();

  /// 鸿蒙在标准 Flutter SDK 无 [Platform.isOhos]，用 operatingSystem 判断。
  static bool get _isOhosPlatform =>
      Platform.operatingSystem.toLowerCase() == 'ohos';

  static bool get _needsRuntimePermission =>
      Platform.isAndroid || Platform.isIOS || _isOhosPlatform;

  /// 申请相机权限；拍视频时传 [withMicrophone] 一并申请麦克风。
  ///
  /// 未授权时**始终**调用系统 `request()`（即使用户曾拒绝）。
  /// 部分机型会在首次使用前误报 [permanentlyDenied]，若此处直接 return
  /// 则永远不弹系统框，业务侧只能 toast「需要权限」——体验像没申请。
  /// 真·永久拒绝时 `request()` 为 no-op，结果仍是 permanentlyDenied。
  static Future<MediaPermissionResult> requestCameraAccess({
    bool withMicrophone = false,
  }) async {
    if (!_needsRuntimePermission) {
      return MediaPermissionResult.granted;
    }

    final permissions = <Permission>[
      Permission.camera,
      if (withMicrophone) Permission.microphone,
    ];

    final before = <PermissionStatus>[
      for (final p in permissions) await p.status,
    ];
    if (_allGranted(before)) return MediaPermissionResult.granted;

    final results = await permissions.request();
    return _classify(results.values);
  }

  static bool _allGranted(Iterable<PermissionStatus> statuses) {
    for (final s in statuses) {
      if (!(s.isGranted || s.isLimited)) return false;
    }
    return true;
  }

  static MediaPermissionResult _classify(Iterable<PermissionStatus> statuses) {
    var allOk = true;
    var anyPermanent = false;
    for (final s in statuses) {
      if (s.isGranted || s.isLimited) continue;
      allOk = false;
      if (s.isPermanentlyDenied || s.isRestricted) {
        anyPermanent = true;
      }
    }
    if (allOk) return MediaPermissionResult.granted;
    if (anyPermanent) return MediaPermissionResult.permanentlyDenied;
    return MediaPermissionResult.denied;
  }

  /// 兼容旧调用：仅相机，返回是否已授权（内部会主动 request）。
  ///
  /// 业务 UI 请优先用 `CameraPermissionGate.ensure`（含去设置引导）。
  static Future<bool> ensureCameraPermission() async {
    final r = await requestCameraAccess();
    return r == MediaPermissionResult.granted;
  }

  /// 打开系统设置页（永久拒绝后引导用户手动开启）。
  static Future<bool> openPermissionSettings() => openAppSettings();

  static Future<String?> pickImage(
    MediaPickSource source, {
    double? maxWidth = 1200,
    int imageQuality = 85,
  }) async {
    final file = await _picker.pickImage(
      source: _toImageSource(source),
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
    return file?.path;
  }

  static Future<String?> pickFromGallery({
    double? maxWidth = 1200,
    int imageQuality = 85,
  }) {
    return pickImage(
      MediaPickSource.gallery,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
  }

  static Future<String?> pickFromCamera({
    double? maxWidth = 1200,
    int imageQuality = 85,
  }) async {
    final r = await requestCameraAccess();
    if (r != MediaPermissionResult.granted) return null;
    return pickImage(
      MediaPickSource.camera,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
  }

  /// 相册多选；返回本地路径列表（可能为空）。
  static Future<List<String>> pickMultiImages({
    double? maxWidth = 1200,
    int imageQuality = 85,
    int? limit,
  }) async {
    final files = await _picker.pickMultiImage(
      maxWidth: maxWidth,
      imageQuality: imageQuality,
      limit: limit,
    );
    return files
        .map((f) => f.path)
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
  }

  /// 选视频。相机源会主动申请相机+麦克风；[skipPermissionCheck] 为 true 时跳过（调用方已申请）。
  static Future<String?> pickVideo(
    MediaPickSource source, {
    bool skipPermissionCheck = false,
  }) async {
    if (source == MediaPickSource.camera && !skipPermissionCheck) {
      final r = await requestCameraAccess(withMicrophone: true);
      if (r != MediaPermissionResult.granted) return null;
    }
    final file = await _picker.pickVideo(source: _toImageSource(source));
    return file?.path;
  }

  static ImageSource _toImageSource(MediaPickSource source) {
    switch (source) {
      case MediaPickSource.gallery:
        return ImageSource.gallery;
      case MediaPickSource.camera:
        return ImageSource.camera;
    }
  }
}
