import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_auth/session/user_profile_sync.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/module_utils.dart';

/// 头像：弹出相册/拍照 → PATCH 资料 → 写入 [UserService]（触发 Mine 等 Obx 刷新）。
abstract final class MineAvatarActions {
  MineAvatarActions._();

  /// 成功返回 true；取消选择返回 false；失败已 toast。
  static Future<bool> pickAndUpload({
    double maxWidth = 800,
    String successToast = '头像已更新',
  }) async {
    if (!Get.isRegistered<UserService>() ||
        Get.find<UserService>().currentUser.value == null) {
      UiKitInitializer.toastError('请先登录');
      return false;
    }

    final source = await MediaSourceBottomSheet.show();
    if (source == null) return false;

    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return false;
        }
      }
      final path = await ImagePickerUtils.pickImage(source, maxWidth: maxWidth);
      if (path == null || path.isEmpty) return false;

      final bytes = await File(path).readAsBytes();
      final mime = _mimeFromPath(path);
      await UserProfileSync.updateAndPersist(
        UpdateUserProfileRequest(
          avatarBase64: base64Encode(bytes),
          avatarMime: mime,
        ),
      );
      UiKitInitializer.toast(successToast);
      return true;
    } on AuthFailure catch (error) {
      UiKitInitializer.toastError(error.message);
      return false;
    } catch (_) {
      UiKitInitializer.toastError('更换头像失败');
      return false;
    }
  }

  static String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
