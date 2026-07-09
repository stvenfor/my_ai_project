import 'dart:async';

import 'package:get/get.dart';
import 'package:module_auth/api/user_auth_api.dart';
import 'package:module_auth/session/device_auth_context.dart';
import 'package:module_core/core.dart';

/// =============================================================================
/// BackendAuthService — 真实登录实现（USE_MOCK_AUTH=false 时启用）
///
/// 流程：UI → AuthController → 本类 → UserAuthApi → Go /api/v1/user/login
/// 成功：token 写入 UserService（SharedPreferences），供 AuthHeaderProvider 读取
///
/// 初学者导读：my_go_study/docs/auth-beginner-walkthrough.md
/// =============================================================================
class BackendAuthService extends AuthService {
  BackendAuthService(this._userService, {UserAuthApi? api})
      : _api = api ?? UserAuthApi();

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
    // Supabase 若开启邮箱验证，register 无 token，需再 login
    if (result.hasSession) {
      await _persistLogin(
        LoginResult(
          token: result.token!,
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
      username: normalizedEmail, // Go 侧 username 即邮箱
      password: password,
      deviceId: device.deviceId,
      platform: device.platform,
    );
    await _persistLogin(result, deviceId: device.deviceId);
  }

  @override
  Future<void> signOut() async {
    await _userService.clearUser();
    _emit(AuthSessionState.signedOut);
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

  /// 把 Go 返回的 token + user 映射为本地 User 模型并持久化。
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
        token: result.token, // Realtime / transactions 都读这个 token
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
