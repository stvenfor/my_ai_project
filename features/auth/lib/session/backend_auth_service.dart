import 'dart:async';

import 'package:get/get.dart';
import 'package:module_auth/api/user_auth_api.dart';
import 'package:module_auth/session/device_auth_context.dart';
import 'package:module_auth/session/user_profile_sync.dart';
import 'package:module_core/core.dart';
import 'package:module_utils/module_utils.dart';

/// =============================================================================
/// BackendAuthService — 真实登录实现（USE_MOCK_AUTH=false 时启用）
///
/// 流程：UI → AuthController → 本类 → UserAuthApi → Go /api/v1/user/login
/// 成功：token + refresh_token 写入 UserService，供 AuthHeaderProvider 读取
///
/// 初学者导读：my_go_study/docs/auth-beginner-walkthrough.md
/// =============================================================================
class BackendAuthService extends AuthService implements SessionRefreshable {
  BackendAuthService(
    this._userService, {
    UserAuthApi? api,
    Future<DeviceAuthPayload> Function()? resolveDevice,
  })  : _api = api ?? UserAuthApi(),
        _resolveDevice = resolveDevice ?? DeviceAuthContext.resolve {
    if (_userService.isLoggedIn) {
      _emit(AuthSessionState.signedIn);
    }
  }

  final UserService _userService;
  final UserAuthApi _api;
  final Future<DeviceAuthPayload> Function() _resolveDevice;
  final _state = AuthSessionState.initial.obs;
  final _events = StreamController<AuthSessionState>.broadcast();

  @override
  AuthSessionState get currentState => _state.value;

  @override
  Stream<AuthSessionState> get authStateChanges => _events.stream;

  void _emit(AuthSessionState next) {
    _state.value = next;
    _events.add(next);
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final normalizedEmail = email.trim();
    final username = _resolveUsername(
      email: normalizedEmail,
      displayName: displayName,
    );
    final device = await _resolveDevice();
    final result = await _api.register(
      username: username,
      password: password,
      email: normalizedEmail,
      deviceId: device.deviceId,
      platform: device.platform,
    );
    if (result.hasSession) {
      await _persistLogin(
        LoginResult(
          token: result.token!,
          refreshToken: result.refreshToken ?? '',
          sessionId: result.sessionId ?? '',
          user: result.user,
        ),
        deviceId: device.deviceId,
      );
      return;
    }
    await signInWithEmail(email: normalizedEmail, password: password);
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final device = await _resolveDevice();
    final result = await _api.login(
      username: normalizedEmail,
      password: password,
      deviceId: device.deviceId,
      platform: device.platform,
    );
    await _persistLogin(result, deviceId: device.deviceId);
  }

  @override
  Future<void> signOut() async {
    final user = _userService.currentUser.value;
    if (user != null &&
        user.token.isNotEmpty &&
        user.sessionId.isNotEmpty &&
        user.deviceId.isNotEmpty) {
      try {
        await _api.logout(
          token: user.token,
          sessionId: user.sessionId,
          deviceId: user.deviceId,
        );
      } catch (error) {
        // Server-Confirmed Logout: only Gone failures clear local session.
        if (!isLogoutSessionGone(error)) {
          rethrow;
        }
      }
    }
    await _userService.clearUser();
    _emit(AuthSessionState.signedOut);
  }

  @override
  Future<void> refreshSession() async {
    final user = _userService.currentUser.value;
    if (user == null || user.refreshToken.isEmpty) return;

    final device = await _resolveDevice();
    final deviceId = user.deviceId.isNotEmpty &&
            !DeviceInfoUtils.isPlaceholderDeviceId(user.deviceId)
        ? user.deviceId
        : device.deviceId;

    try {
      final result = await _api.refresh(
        refreshToken: user.refreshToken,
        deviceId: deviceId,
        sessionId: user.sessionId,
        platform: device.platform,
      );
      await _userService.updateAuthTokens(
        token: result.token,
        refreshToken: result.refreshToken,
        sessionId: result.sessionId,
      );
      if (user.deviceId != deviceId) {
        final current = _userService.currentUser.value;
        if (current != null) {
          await _userService.setUser(current.copyWith(deviceId: deviceId));
        }
      }
      _emit(AuthSessionState.signedIn);
    } catch (error) {
      // 互踢/会话已失效：向上抛出，避免 SessionRecovery 误判成功。
      if (isLogoutSessionGone(error)) rethrow;
      // Cold Start Keep: 网络等失败不得清掉本地 Auth Session。
    }
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    final e164 = PhoneAuthUtils.toE164China(phone);
    await _api.sendPhoneOtp(phone: e164);
  }

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    final e164 = PhoneAuthUtils.toE164China(phone);
    final device = await _resolveDevice();
    final result = await _api.verifyPhoneOtp(
      phone: e164,
      otp: otp.trim(),
      deviceId: device.deviceId,
      platform: device.platform,
    );
    await _persistLogin(
      result,
      deviceId: device.deviceId,
      loginPhone: phone,
    );
  }

  @override
  Future<void> signInWithWechatCode({required String code}) async {
    final device = await _resolveDevice();
    final result = await _api.loginWithWechat(
      code: code.trim(),
      deviceId: device.deviceId,
      platform: device.platform,
    );
    await _persistLogin(result, deviceId: device.deviceId);
  }

  Future<void> _persistLogin(
    LoginResult result, {
    required String deviceId,
    String? loginPhone,
  }) async {
    // 作废上一账号未完成的 hydrate，避免旧资料盖住新登录。
    UserProfileSync.invalidatePendingHydrates();

    final backendUser = result.user;
    final displayName = backendUser.username.isNotEmpty
        ? backendUser.username
        : backendUser.email.split('@').first;
    // 登录手机号优先：防止响应用户字段缺失/错绑时展示串号。
    final rawPhone = () {
      final fromLogin = PhoneAuthUtils.normalizeDigits(loginPhone ?? '');
      if (fromLogin.isNotEmpty) return fromLogin;
      final fromUser = backendUser.phone.trim();
      if (fromUser.isNotEmpty) return fromUser;
      return backendUser.email.split('@').first;
    }();
    final phoneMasked = UserProfileSync.maskPhone(rawPhone);
    await _userService.setUser(
      User(
        id: backendUser.id,
        name: displayName,
        avatar: backendUser.avatarUrl,
        token: result.token,
        refreshToken: result.refreshToken,
        sessionId: result.sessionId,
        deviceId: deviceId,
        phoneMasked: phoneMasked,
      ),
    );
    _emit(AuthSessionState.signedIn);
    unawaited(UserProfileSync.hydrateQuietly(userService: _userService));
  }

  String _resolveUsername({
    required String email,
    String? displayName,
  }) {
    final trimmedName = displayName?.trim() ?? '';
    if (trimmedName.isNotEmpty) return trimmedName;
    final localPart = email.split('@').first;
    return localPart.isNotEmpty ? localPart : email;
  }

  @override
  void onClose() {
    _events.close();
    super.onClose();
  }
}

/// True when logout failure means the server session is already gone / invalid.
///
/// Used by Server-Confirmed Logout so Gone clears local Auth Session while
/// network and other failures keep it.
bool isLogoutSessionGone(Object error) {
  if (error is SessionReplacedFailure || error is SessionInvalidFailure) {
    return true;
  }
  if (error is InvalidCredentialsFailure) return true;
  if (error is! AuthFailure) return false;
  final text = error.message;
  if (text.contains('Unauthorized')) return true;
  if (text.contains('未登录')) return true;
  if (text.toLowerCase().contains('session not found')) return true;
  if (text.contains('会话不存在') || text.contains('会话已失效')) return true;
  return false;
}
