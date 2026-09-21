import 'package:get/get.dart';
import 'package:module_auth/api/user_profile_api.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/module_utils.dart';

/// 将会话 [User] 与正式 profile 合并，并在登录后 / 资料页拉取。
abstract final class UserProfileSync {
  UserProfileSync._();

  static final UserProfileApi _api = UserProfileApi();

  /// 拉取 `/profiles/me` 并写入 [UserService]；失败不抛出、不登出。
  static Future<bool> hydrateQuietly({UserService? userService}) async {
    if (!Get.isRegistered<UserService>()) return false;
    final service = userService ?? Get.find<UserService>();
    final current = service.currentUser.value;
    if (current == null || current.token.isEmpty) return false;

    try {
      final profile = await _api.fetchMe();
      await service.setUser(mergeProfile(current, profile));
      return true;
    } catch (error, stack) {
      LogUtils.w('[UserProfileSync] hydrate failed', error, stack);
      return false;
    }
  }

  static Future<UserProfile> updateAndPersist(
    UpdateUserProfileRequest request, {
    UserService? userService,
  }) async {
    if (!Get.isRegistered<UserService>()) {
      throw const UnknownAuthFailure('请先登录');
    }
    final service = userService ?? Get.find<UserService>();
    final current = service.currentUser.value;
    if (current == null) {
      throw const UnknownAuthFailure('请先登录');
    }
    final profile = await _api.updateMe(request);
    await service.setUser(mergeProfile(current, profile));
    return profile;
  }

  static User mergeProfile(User current, UserProfile profile) {
    final name = profile.displayName.isNotEmpty
        ? profile.displayName
        : (profile.userName.isNotEmpty ? profile.userName : current.name);
    final avatar =
        profile.avatarUrl.isNotEmpty ? profile.avatarUrl : current.avatar;
    return current.copyWith(
      id: profile.userId.isNotEmpty
          ? profile.userId
          : (profile.id.isNotEmpty ? profile.id : current.id),
      name: name,
      avatar: avatar,
      phoneMasked: maskPhone(profile.phone),
    );
  }

  static String maskPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 11) {
      final local = digits.substring(digits.length - 11);
      return '${local.substring(0, 3)}****${local.substring(7)}';
    }
    if (digits.length >= 7) {
      return '${digits.substring(0, 3)}****${digits.substring(digits.length - 4)}';
    }
    if (raw.trim().isEmpty) return '';
    return raw;
  }
}
