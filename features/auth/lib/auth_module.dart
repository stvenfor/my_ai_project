import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/view/login_otp_page.dart';
import 'package:module_auth/user/view/login_page.dart';
import 'package:module_auth/user/view/login_password_page.dart';
import 'package:module_auth/user/view/register_page.dart';
import 'package:wys_router/src/module/feature_module.dart';
import 'package:wys_router/src/module/module_host_context.dart';
import 'package:wys_router/src/route/route_path.dart';

class AuthModule extends FeatureModule {
  @override
  String get moduleId => 'auth';

  @override
  Bindings? createBinding() => AuthBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.login: (_) => const LoginPage(),
        RoutePath.loginPassword: (_) => const LoginPasswordPage(),
        RoutePath.loginOtp: (_) => const LoginOtpPage(),
        RoutePath.register: (_) => const RegisterPage(),
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    // Standalone is not a product Login Gate (ADR 0007): do not force mock
    // or wire a post-login standalone destination. Shell registers AuthSession.
    if (context.isStandalone) {
      return;
    }
    await AuthSession.register();
  }
}
