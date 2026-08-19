import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum MediaPickSource { gallery, camera }

class ImagePickerUtils {
  ImagePickerUtils._();

  static final ImagePicker _picker = ImagePicker();

  /// 鸿蒙在标准 Flutter SDK 无 [Platform.isOhos]，用 operatingSystem 判断。
  static bool get _isOhosPlatform =>
      Platform.operatingSystem.toLowerCase() == 'ohos';

  static Future<bool> ensureCameraPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS && !_isOhosPlatform) {
      return true;
    }

    final status = await Permission.camera.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }

    final result = await Permission.camera.request();
    return result.isGranted || result.isLimited;
  }

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
    final granted = await ensureCameraPermission();
    if (!granted) return null;
    return pickImage(
      MediaPickSource.camera,
      maxWidth: maxWidth,
      imageQuality: imageQuality,
    );
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
