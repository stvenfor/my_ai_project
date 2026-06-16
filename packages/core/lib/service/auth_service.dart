import 'package:get/get.dart';
import 'package:module_core/model/auth/auth_session_state.dart';

/// 认证操作抽象服务，业务 Controller 只依赖此接口。
abstract class AuthService extends GetxService {
  Stream<AuthSessionState> get authStateChanges;

  AuthSessionState get currentState;

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// 发送手机短信验证码（登录/注册共用，Supabase 首次验证即注册）。
  Future<void> sendPhoneOtp({required String phone});

  /// 校验短信验证码并完成登录/注册。
  Future<void> verifyPhoneOtp({
    required String phone,
    required String otp,
  });

  Future<void> signOut();
}
