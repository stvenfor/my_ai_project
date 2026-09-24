import 'dart:async';

import 'package:get/get.dart';
import 'package:module_core/model/auth/auth_failure.dart';
import 'package:module_core/model/auth/auth_session_state.dart';
import 'package:module_core/model/auth/phone_auth_utils.dart';
import 'package:module_core/model/user.dart';
import 'package:module_core/service/auth_service.dart';
import 'package:module_core/service/user_service.dart';

/// 模块独立运行 / USE_MOCK_AUTH 时的认证实现（不请求 Go 后端）。
class MockAuthService extends AuthService {
  MockAuthService(this._userService);

  /// Mock 环境下固定测试手机号与验证码（与 Go AUTH_DEV_TEST_PHONE 对齐）。
  static const mockTestPhones = {
    '13400000000',
    '13400000001',
    '13400000002',
    '13400000003',
    '13400000004',
  };
  static const mockOtpCode = '123456';

  /// 兼容旧引用。
  static const mockTestPhone = '13400000000';

  static const _displayNames = {
    '13400000000': '测试甲',
    '13400000001': '测试乙',
    '13400000002': '测试丙',
    '13400000003': '测试丁',
    '13400000004': '测试戊',
  };

  final UserService _userService;
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
    await signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final localPart = email.split('@').first;
    await _userService.setUser(
      User(
        id: 'mock_$localPart',
        name: '用户$localPart',
        avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=$localPart',
        token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    _emit(AuthSessionState.signedIn);
  }

  @override
  Future<void> signOut() async {
    await _userService.clearUser();
    _emit(AuthSessionState.signedOut);
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    final digits = PhoneAuthUtils.normalizeDigits(phone);
    if (!mockTestPhones.contains(digits)) {
      throw UnknownAuthFailure('测试环境请使用 ${mockTestPhones.join(" / ")}');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    final digits = PhoneAuthUtils.normalizeDigits(phone);
    if (!mockTestPhones.contains(digits)) {
      throw UnknownAuthFailure('测试环境请使用 ${mockTestPhones.join(" / ")}');
    }
    if (otp.trim() != mockOtpCode) {
      throw const InvalidOtpFailure();
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final label = _displayNames[digits] ?? '用户${digits.substring(digits.length - 4)}';
    final masked = digits.length >= 11
        ? '${digits.substring(0, 3)}****${digits.substring(7)}'
        : digits;
    await _userService.setUser(
      User(
        id: 'mock_phone_$digits',
        name: label,
        avatar: 'https://picsum.photos/seed/im_$digits/200/200',
        token: 'mock_phone_token_${DateTime.now().millisecondsSinceEpoch}',
        phoneMasked: masked,
      ),
    );
    _emit(AuthSessionState.signedIn);
  }

  @override
  Future<void> signInWithWechatCode({required String code}) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      throw UnknownAuthFailure('微信授权码为空');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _userService.setUser(
      User(
        id: 'mock_wx_${trimmed.hashCode.abs()}',
        name: '微信用户',
        avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=wechat',
        token: 'mock_wx_token_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    _emit(AuthSessionState.signedIn);
  }

  @override
  void onClose() {
    _events.close();
    super.onClose();
  }
}
