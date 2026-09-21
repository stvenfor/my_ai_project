import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_auth/navigation/auth_navigation.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/session/user_profile_sync.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/module_utils.dart';

class MineProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();

  final nicknameController = TextEditingController();
  final nicknameFocus = FocusNode();
  final avatarPreview = ''.obs;
  final phoneMasked = ''.obs;
  final saving = false.obs;
  final dirty = false.obs;

  String _savedNickname = '';
  String? _pendingAvatarBase64;
  String _pendingAvatarMime = 'image/jpeg';
  bool _applyingLocal = false;

  @override
  void onInit() {
    super.onInit();
    _fillFromLocal(_userService.currentUser.value);
    nicknameController.addListener(_onNicknameChanged);
    ever(_userService.currentUser, (User? next) {
      if (next == null || dirty.value || saving.value) return;
      phoneMasked.value = next.phoneMasked;
      if (!nicknameFocus.hasFocus) {
        _applyNicknameFromUser(next.name);
      }
      if (_pendingAvatarBase64 == null) {
        avatarPreview.value = next.avatar;
      }
    });
    UserProfileSync.hydrateQuietly();
  }

  void _fillFromLocal(User? user) {
    if (user == null) return;
    _applyingLocal = true;
    _applyNicknameFromUser(user.name);
    avatarPreview.value = user.avatar;
    phoneMasked.value = user.phoneMasked;
    dirty.value = false;
    _applyingLocal = false;
  }

  void _applyNicknameFromUser(String name) {
    _savedNickname = name;
    if (nicknameController.text != name) {
      nicknameController.text = name;
    }
  }

  void _onNicknameChanged() {
    if (_applyingLocal) return;
    _refreshDirty();
  }

  void _refreshDirty() {
    final nickChanged = nicknameController.text.trim() != _savedNickname;
    final avatarChanged = _pendingAvatarBase64 != null;
    dirty.value = nickChanged || avatarChanged;
  }

  /// 只选图预览，不调接口。
  Future<void> pickAvatar() async {
    if (saving.value) return;
    final source = await MediaSourceBottomSheet.show();
    if (source == null) return;

    try {
      if (source == MediaPickSource.camera) {
        final granted = await ImagePickerUtils.ensureCameraPermission();
        if (!granted) {
          UiKitInitializer.toastError('需要相机权限才能拍摄');
          return;
        }
      }
      final path = await ImagePickerUtils.pickImage(source, maxWidth: 800);
      if (path == null || path.isEmpty) return;

      final bytes = await File(path).readAsBytes();
      _pendingAvatarBase64 = base64Encode(bytes);
      _pendingAvatarMime = _mimeFromPath(path);
      avatarPreview.value =
          'data:$_pendingAvatarMime;base64,$_pendingAvatarBase64';
      _refreshDirty();
    } catch (_) {
      UiKitInitializer.toastError('选择图片失败');
    }
  }

  /// 右上角保存：昵称 + 待上传头像一并提交。
  Future<void> save() async {
    if (saving.value) return;
    nicknameFocus.unfocus();

    final nickname = nicknameController.text.trim();
    if (nickname.isEmpty) {
      UiKitInitializer.toastError('昵称不能为空');
      return;
    }
    if (!dirty.value) {
      UiKitInitializer.toast('没有需要保存的修改');
      return;
    }

    saving.value = true;
    try {
      await UserProfileSync.updateAndPersist(
        UpdateUserProfileRequest(
          displayName: nickname != _savedNickname ? nickname : null,
          avatarBase64: _pendingAvatarBase64,
          avatarMime:
              _pendingAvatarBase64 == null ? null : _pendingAvatarMime,
        ),
      );
      _savedNickname = nickname;
      _pendingAvatarBase64 = null;
      final user = _userService.currentUser.value;
      if (user != null) {
        avatarPreview.value = user.avatar;
        phoneMasked.value = user.phoneMasked;
      }
      dirty.value = false;
      UiKitInitializer.toast('资料已保存');
    } on AuthFailure catch (error) {
      UiKitInitializer.toastError(error.message);
    } catch (_) {
      UiKitInitializer.toastError('保存失败，请稍后重试');
    } finally {
      saving.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await AuthSession.logout();
    } on AuthFailure catch (error) {
      UiKitInitializer.toast(error.message);
      return;
    } catch (_) {
      UiKitInitializer.toast('登出失败，请稍后重试');
      return;
    }
    await AuthNavigation.resetToLogin();
  }

  static String _mimeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  @override
  void onClose() {
    nicknameController.removeListener(_onNicknameChanged);
    nicknameFocus.dispose();
    nicknameController.dispose();
    super.onClose();
  }
}
