import 'dart:async';

import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_core/core.dart';
import 'package:wys_router/src/module/module_registry.dart';
import 'package:wys_router/src/route/login_redirect.dart';
import 'package:wys_router/src/route/route_path.dart';
import 'package:module_utils/module_utils.dart';

class AuthController extends GetxController {
  AuthController({
    AuthService? authService,
    UserService? userService,
    AppLoading? loading,
  })  : _authService = authService ?? _resolveAuthService(),
        _userService = userService ?? Get.find<UserService>(),
        _loading = loading ?? Get.find<AppLoading>();

  /// 独立运行 main_dev 时设为 true
  static bool standaloneMode = false;

  final AuthService _authService;
  final UserService _userService;
  final AppLoading _loading;

  static AuthService _resolveAuthService() {
    if (Get.isRegistered<AuthService>()) {
      return Get.find<AuthService>();
    }
    throw StateError('AuthService 未注册，请先调用 AuthSession.register()');
  }

  final isLoading = false.obs;
  final agreedPrivacy = true.obs;
  final credentialMode = AuthCredentialMode.email.obs;

  final email = ''.obs;
  final phone = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;
  final displayName = ''.obs;
  final otpCode = ''.obs;
  final otpCooldownSeconds = 0.obs;
  final phoneOtpSent = false.obs;

  static const _lastLoginEmailKey = 'auth_last_login_email';
  static const _lastLoginPasswordKey = 'auth_last_login_password';
  static const _lastLoginPhoneKey = 'auth_last_login_phone';
  static const _lastLoginModeKey = 'auth_last_login_mode';

  String _pendingEmail = '';
  String _pendingPhone = '';
  Timer? _otpTimer;

  @override
  void onInit() {
    super.onInit();
    _restoreLastLoginCredentials();
  }

  /// 从本地恢复上次登录成功的邮箱/密码、手机号，以及登录方式 Tab。
  void _restoreLastLoginCredentials() {
    final savedEmail = SpUtils.getString(_lastLoginEmailKey);
    final savedPassword = SpUtils.getString(_lastLoginPasswordKey);
    final savedPhone = SpUtils.getString(_lastLoginPhoneKey);
    final savedMode = SpUtils.getString(_lastLoginModeKey);

    if (savedEmail != null && savedEmail.isNotEmpty) {
      email.value = savedEmail;
      _pendingEmail = savedEmail;
    }
    if (savedPassword != null && savedPassword.isNotEmpty) {
      password.value = savedPassword;
    }
    if (savedPhone != null && savedPhone.isNotEmpty) {
      phone.value = savedPhone;
      _pendingPhone = savedPhone;
    }

    if (savedMode == AuthCredentialMode.phone.name) {
      credentialMode.value = AuthCredentialMode.phone;
    } else if (savedMode == AuthCredentialMode.email.name) {
      credentialMode.value = AuthCredentialMode.email;
    }
  }

  /// 邮箱登录成功后记住邮箱 + 密码（仅本地）。
  Future<void> _persistEmailLoginCredentials(String loginEmail) async {
    final normalized = loginEmail.trim();
    _pendingEmail = normalized;
    email.value = normalized;
    await SpUtils.setString(_lastLoginEmailKey, normalized);
    await SpUtils.setString(_lastLoginPasswordKey, password.value);
    await SpUtils.setString(_lastLoginModeKey, AuthCredentialMode.email.name);
  }

  /// 短信登录成功后记住手机号（仅本地，不存验证码）。
  Future<void> _persistPhoneLoginCredentials(String loginPhone) async {
    final normalized = PhoneAuthUtils.normalizeDigits(loginPhone);
    _pendingPhone = normalized;
    phone.value = normalized;
    await SpUtils.setString(_lastLoginPhoneKey, normalized);
    await SpUtils.setString(_lastLoginModeKey, AuthCredentialMode.phone.name);
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早上好，欢迎使用iHome';
    if (hour < 18) return '下午好，欢迎使用iHome';
    return '晚上好，欢迎使用iHome';
  }

  static const minPasswordLength = 6;

  bool get isPasswordValid => password.value.length >= minPasswordLength;

  bool get isLoginPasswordValid => isPasswordValid;

  bool get isRegisterPasswordMatch =>
      password.value == confirmPassword.value && isPasswordValid;

  bool get canResendOtp => otpCooldownSeconds.value <= 0 && !isLoading.value;

  bool get isOtpValid => RegExp(r'^\d{6}$').hasMatch(otpCode.value.trim());

  bool get canSendPhoneOtp =>
      agreedPrivacy.value &&
      validatePhone(phone.value) &&
      canResendOtp;

  bool get canLoginWithPhoneOtp =>
      agreedPrivacy.value &&
      validatePhone(phone.value) &&
      isOtpValid;

  void switchCredentialMode(AuthCredentialMode mode) {
    credentialMode.value = mode;
  }

  void updateEmail(String value) {
    final trimmed = value.trim();
    email.value = trimmed;
    _pendingEmail = trimmed;
  }

  void updatePhone(String value) => phone.value = value;

  void updatePassword(String value) => password.value = value;

  void updateConfirmPassword(String value) => confirmPassword.value = value;

  void updateDisplayName(String value) => displayName.value = value.trim();

  void updateOtpCode(String value) => otpCode.value = value;

  void togglePrivacy(bool? value) {
    if (value != null) agreedPrivacy.value = value;
  }

  bool validateEmail(String raw) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(raw.trim());
  }

  bool validatePhone(String raw) => PhoneAuthUtils.isValidChinaMobile(raw);

  void _showToast(String message) => _loading.showToast(message);

  void _logAuth(String tag, String message, {Object? error, String level = 'info'}) {
    final line = switch (error) {
      null => '[$tag] $message',
      AuthFailure() => '[$tag] $message',
      _ => '[$tag] $message | $error',
    };
    switch (level) {
      case 'error':
        LogUtils.e(line);
      case 'success':
        LogUtils.i(line);
      default:
        LogUtils.i(line);
    }
  }

  void _showLoginToast(String message) {
    _logAuth('AuthLogin', 'toast: $message');
    _showToast(message);
  }

  void _showLoginAuthFailure(Object error) {
    final message =
        error is AuthFailure ? error.message : '操作失败，请稍后重试';
    _logAuth('AuthLogin', 'toast: $message', error: error, level: 'error');
    if (error is AccountNotRegisteredFailure) {
      _loading.showError(message);
      Future.microtask(() {
        Get.defaultDialog<void>(
          title: '提示',
          middleText: message,
          textCancel: '取消',
          textConfirm: '去注册',
          onConfirm: () {
            Get.back<void>();
            Get.toNamed(RoutePath.register);
          },
        );
      });
      return;
    }
    _showAuthFailure(error is AuthFailure ? error : UnknownAuthFailure(message));
  }

  void _showAuthFailure(Object error) {
    final message =
        error is AuthFailure ? error.message : '操作失败：$error';
    if (error is EmailConfirmationRequiredFailure) {
      _loading.showInfo(message);
    } else {
      _loading.showError(message);
    }
  }

  void _logRegister(String message, {Object? error, String level = 'info'}) {
    _logAuth('AuthRegister', message, error: error, level: level);
  }

  void _showRegisterToast(String message) {
    _logRegister('toast: $message');
    _showToast(message);
  }

  void _showRegisterAuthFailure(Object error) {
    final message = error is AuthFailure
        ? error.message
        : '操作失败，请稍后重试';
    _logRegister('toast: $message', error: error, level: 'error');
    _showAuthFailure(error is AuthFailure ? error : UnknownAuthFailure(message));
  }

  void _showRegisterSuccess(String message) {
    _logRegister('toast: $message', level: 'success');
    _loading.showSuccess(message);
  }

  Future<void> _refreshUserSession() async {
    if (_userService is SessionRefreshable) {
      await (_userService as SessionRefreshable).refreshSession();
    }
  }

  Future<void> _navigateAfterAuth() async {
    if (!_userService.isLoggedIn) {
      await _refreshUserSession();
    }
    if (!_userService.isLoggedIn) return;

    final redirect = LoginRedirect.takePending();

    if (standaloneMode) {
      Get.offAllNamed(RoutePath.authDevHome);
      return;
    }

    ModuleRegistry.ensureBindings();
    Get.offAllNamed(RoutePath.main);
    Future.microtask(() async {
      if (await LoginRedirect.notifyAfterAuthNavigation()) return;
      if (redirect != null) {
        Get.toNamed(redirect);
      }
      await AuthSession.notifyAfterLogin();
    });
  }

  Future<bool> sendPhoneOtp({bool fromRegister = false}) async {
    AppKeyboard.dismiss();
    void toast(String message) =>
        fromRegister ? _showRegisterToast(message) : _showToast(message);
    void fail(Object error) =>
        fromRegister ? _showRegisterAuthFailure(error) : _showAuthFailure(error);

    if (!agreedPrivacy.value) {
      toast('请先阅读并同意隐私条款');
      return false;
    }
    if (!validatePhone(phone.value)) {
      toast('请输入有效的手机号');
      return false;
    }
    if (!AppDebounce.tryThrottle('auth.sendPhoneOtp')) {
      return false;
    }

    isLoading.value = true;
    try {
      _pendingPhone = PhoneAuthUtils.normalizeDigits(phone.value);
      await _authService.sendPhoneOtp(phone: _pendingPhone);
      _startOtpCooldown(60);
      phoneOtpSent.value = true;
      toast('验证码已发送');
      return true;
    } catch (error) {
      fail(error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPhoneOtpAndGo({bool fromRegister = false}) async {
    if (await sendPhoneOtp(fromRegister: fromRegister)) {
      await Get.toNamed(RoutePath.loginOtp);
    }
  }

  Future<void> resendPhoneOtp() async {
    AppKeyboard.dismiss();
    if (!canResendOtp) return;
    final targetPhone =
        _pendingPhone.isNotEmpty ? _pendingPhone : phone.value;
    if (!validatePhone(targetPhone)) {
      _showToast('手机号无效');
      return;
    }
    if (!AppDebounce.tryThrottle('auth.resendPhoneOtp')) {
      return;
    }

    isLoading.value = true;
    try {
      await _authService.sendPhoneOtp(phone: targetPhone);
      _startOtpCooldown(60);
      _showToast('验证码已重新发送');
    } catch (error) {
      _showAuthFailure(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPhoneOtp({bool fromRegister = false}) async {
    AppKeyboard.dismiss();
    void toast(String message) =>
        fromRegister ? _showRegisterToast(message) : _showToast(message);
    void fail(Object error) => fromRegister
        ? _showRegisterAuthFailure(error)
        : _showAuthFailure(error);

    if (!agreedPrivacy.value) {
      toast('请先阅读并同意隐私条款');
      return;
    }
    if (!isOtpValid) {
      toast('请输入 6 位验证码');
      return;
    }

    final targetPhone =
        _pendingPhone.isNotEmpty ? _pendingPhone : phone.value;
    if (!validatePhone(targetPhone)) {
      toast('手机号无效');
      return;
    }
    if (!AppDebounce.tryThrottle('auth.verifyPhoneOtp')) {
      return;
    }

    isLoading.value = true;
    try {
      await _authService.verifyPhoneOtp(
        phone: targetPhone,
        otp: otpCode.value.trim(),
      );
      await _persistPhoneLoginCredentials(targetPhone);
      otpCode.value = '';
      if (fromRegister) {
        _showRegisterSuccess('注册成功');
      }
      await _navigateAfterAuth();
    } catch (error) {
      fail(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithPassword() async {
    AppKeyboard.dismiss();
    if (!agreedPrivacy.value) {
      _showLoginToast('请先阅读并同意隐私条款');
      return;
    }
    if (!validateEmail(email.value)) {
      _showLoginToast('请输入有效的邮箱');
      return;
    }
    if (!isLoginPasswordValid) {
      _showLoginToast('请输入至少6位密码');
      return;
    }
    if (!AppDebounce.tryThrottle('auth.loginWithPassword')) {
      return;
    }

    isLoading.value = true;
    final loginEmail = email.value.trim();
    _pendingEmail = loginEmail;
    _logAuth('AuthLogin', 'start: email=$loginEmail');
    try {
      await _authService.signInWithEmail(
        email: loginEmail,
        password: password.value,
      );
      _logAuth('AuthLogin', 'success: email=$loginEmail', level: 'success');
      await _persistEmailLoginCredentials(loginEmail);
      await _navigateAfterAuth();
    } catch (error) {
      _showLoginAuthFailure(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerWithEmail() async {
    AppKeyboard.dismiss();
    if (!agreedPrivacy.value) {
      _showRegisterToast('请先阅读并同意隐私条款');
      return;
    }
    if (!validateEmail(email.value)) {
      _showRegisterToast('请输入有效的邮箱');
      return;
    }
    if (!isRegisterPasswordMatch) {
      if (password.value.length < minPasswordLength) {
        _showRegisterToast('请输入至少6位密码');
      } else {
        _showRegisterToast('两次密码不一致');
      }
      return;
    }
    if (!AppDebounce.tryThrottle('auth.registerWithEmail')) {
      return;
    }

    isLoading.value = true;
    _logRegister(
      'start: email=${email.value.trim()}, displayName=${displayName.value.isEmpty ? '(空)' : displayName.value}',
    );
    try {
      await _authService.signUpWithEmail(
        email: email.value.trim(),
        password: password.value,
        displayName: displayName.value.isEmpty ? null : displayName.value,
      );
      await _refreshUserSession();
      final registeredEmail = email.value.trim();
      await _persistEmailLoginCredentials(registeredEmail);
      _showRegisterSuccess('注册成功');
      await _navigateAfterAuth();
    } catch (error) {
      _showRegisterAuthFailure(error);
    } finally {
      isLoading.value = false;
    }
  }

  /// 手机号注册：同页填写验证码，首次验证通过自动创建账号。
  Future<void> registerWithPhone() async {
    _logRegister('start: phone=${phone.value}');
    await verifyPhoneOtp(fromRegister: true);
  }

  void _startOtpCooldown(int seconds) {
    _otpTimer?.cancel();
    otpCooldownSeconds.value = seconds;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpCooldownSeconds.value <= 1) {
        otpCooldownSeconds.value = 0;
        timer.cancel();
      } else {
        otpCooldownSeconds.value--;
      }
    });
  }

  Future<void> logout() async {
    await AuthSession.logout();
    Get.offAllNamed(RoutePath.login);
  }

  String get maskedPendingPhone {
    if (_pendingPhone.length != 11) return _pendingPhone;
    return '${_pendingPhone.substring(0, 3)}****${_pendingPhone.substring(7)}';
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    super.onClose();
  }
}
