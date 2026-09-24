import 'package:get/get.dart';
import 'package:module_auth/api/user_profile_api.dart';
import 'package:module_auth/api/user_profile_models.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/module_utils.dart';

/// 将会话 [User] 与正式 profile 合并，并在登录后 / 资料页拉取。
abstract final class UserProfileSync {
  UserProfileSync._();

  static final UserProfileApi _api = UserProfileApi();

  /// 递增以作废进行中的 hydrate（换号登录时旧请求不得回写）。
  static int _hydrateEpoch = 0;

  /// 作废所有未完成的 hydrate（登录切换账号前调用）。
  static void invalidatePendingHydrates() {
    _hydrateEpoch++;
  }

  /// 拉取 `/profiles/me` 并写入 [UserService]；失败不抛出、不登出。
  ///
  /// 若期间用户已切换（换号登录），丢弃本次结果，避免旧账号资料盖住新会话。
  static Future<bool> hydrateQuietly({UserService? userService}) async {
    if (!Get.isRegistered<UserService>()) return false;
    final service = userService ?? Get.find<UserService>();
    final current = service.currentUser.value;
    if (current == null || current.token.isEmpty) return false;

    final epoch = _hydrateEpoch;
    final expectedUserId = current.id;

    try {
      final profile = await _api.fetchMe();
      if (epoch != _hydrateEpoch) return false;

      final latest = service.currentUser.value;
      if (latest == null || latest.id != expectedUserId) return false;

      final profileId = profile.userId.isNotEmpty
          ? profile.userId
          : profile.id;
      if (profileId.isNotEmpty && profileId != latest.id) {
        LogUtils.w(
          '[UserProfileSync] drop mismatched profile '
          'expected=$expectedUserId got=$profileId',
        );
        return false;
      }

      await service.setUser(mergeProfile(latest, profile));
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

  /// 合并资料；**永不改写为其它 userId**（防止串号）。
  static User mergeProfile(User current, UserProfile profile) {
    final profileId =
        profile.userId.isNotEmpty ? profile.userId : profile.id;
    if (profileId.isNotEmpty && profileId != current.id) {
      return current;
    }
    final name = profile.displayName.isNotEmpty
        ? profile.displayName
        : (profile.userName.isNotEmpty ? profile.userName : current.name);
    final avatar =
        profile.avatarUrl.isNotEmpty ? profile.avatarUrl : current.avatar;
    final phoneMasked = profile.phone.trim().isNotEmpty
        ? maskPhone(profile.phone)
        : current.phoneMasked;
    return current.copyWith(
      name: name,
      avatar: avatar,
      phoneMasked: phoneMasked,
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
