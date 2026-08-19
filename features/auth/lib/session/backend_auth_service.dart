import 'dart:async';

import 'package:get/get.dart';
import 'package:module_auth/api/user_auth_api.dart';
import 'package:module_auth/session/device_auth_context.dart';
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
  BackendAuthService(this._userService, {UserAuthApi? api})
      : _api = api ?? UserAuthApi() {
    if (_userService.isLoggedIn) {
      _emit(AuthSessionState.signedIn);
    }
  }

  final UserService _userService;
  final UserAuthApi _api;
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
    final device = await DeviceAuthContext.resolve();
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
    final device = await DeviceAuthContext.resolve();
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
      } catch (_) {
        // 退出以清本地凭证为准；服务端失败不阻塞 UI。
      }
    }
    await _userService.clearUser();
    _emit(AuthSessionState.signedOut);
  }

  @override
  Future<void> refreshSession() async {
    final user = _userService.currentUser.value;
    if (user == null || user.refreshToken.isEmpty) return;

    final device = await DeviceAuthContext.resolve();
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
    } catch (_) {
      await _userService.clearUser();
      _emit(AuthSessionState.signedOut);
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
    final device = await DeviceAuthContext.resolve();
    final result = await _api.verifyPhoneOtp(
      phone: e164,
      otp: otp.trim(),
      deviceId: device.deviceId,
      platform: device.platform,
    );
    await _persistLogin(result, deviceId: device.deviceId);
  }

  Future<void> _persistLogin(
    LoginResult result, {
    required String deviceId,
  }) async {
    final backendUser = result.user;
    final displayName = backendUser.username.isNotEmpty
        ? backendUser.username
        : backendUser.email.split('@').first;
    await _userService.setUser(
      User(
        id: backendUser.id,
        name: displayName,
        avatar: '',
        token: result.token,
        refreshToken: result.refreshToken,
        sessionId: result.sessionId,
        deviceId: deviceId,
      ),
    );
    _emit(AuthSessionState.signedIn);
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
