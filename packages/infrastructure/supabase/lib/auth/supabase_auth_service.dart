import 'dart:async';

import 'package:get/get.dart';
import 'package:module_core/model/auth/auth_session_state.dart';
import 'package:module_core/model/auth/phone_auth_utils.dart';
import 'package:module_core/service/auth_service.dart';
import 'package:module_supabase/auth/supabase_auth_runner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 基于 supabase_flutter [GoTrueClient] 的认证实现。
class SupabaseAuthService extends AuthService {
  SupabaseAuthService(
    SupabaseClient client, {
    Future<void> Function()? onAuthenticated,
  }) : _runner = SupabaseAuthRunner(client.auth, onAuthenticated: onAuthenticated);

  final SupabaseAuthRunner _runner;
  final _state = AuthSessionState.initial.obs;
  StreamSubscription<AuthState>? _subscription;

  GoTrueClient get _auth => _runner.auth;

  @override
  AuthSessionState get currentState => _state.value;

  @override
  Stream<AuthSessionState> get authStateChanges =>
      _auth.onAuthStateChange.map(_mapAuthState);

  AuthSessionState _mapAuthState(AuthState state) {
    return switch (state.event) {
      AuthChangeEvent.signedIn ||
      AuthChangeEvent.tokenRefreshed ||
      AuthChangeEvent.userUpdated =>
        AuthSessionState.signedIn,
      AuthChangeEvent.signedOut => AuthSessionState.signedOut,
      _ => _auth.currentSession != null
          ? AuthSessionState.signedIn
          : AuthSessionState.signedOut,
    };
  }

  Future<void> bindAuthListener(void Function(AuthSessionState) onChange) async {
    _state.value = _auth.currentSession != null
        ? AuthSessionState.signedIn
        : AuthSessionState.signedOut;

    await _subscription?.cancel();
    _subscription = _auth.onAuthStateChange.listen((event) {
      final next = _mapAuthState(event);
      _state.value = next;
      onChange(next);
    });
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    await _runner.run((auth) async {
      final response = await auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          if (displayName != null && displayName.isNotEmpty)
            'display_name': displayName,
        },
      );
      _runner.assertSignUpSucceeded(response);
      return response;
    });
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _runner.run(
      (auth) => auth.signInWithPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await _runner.run((auth) => auth.signOut());
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    await _runner.run(
      (auth) => auth.signInWithOtp(phone: PhoneAuthUtils.toE164China(phone)),
    );
  }

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    await _runner.run(
      (auth) => auth.verifyOTP(
        type: OtpType.sms,
        phone: PhoneAuthUtils.toE164China(phone),
        token: otp.trim(),
      ),
    );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
