import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/user/view/auth_dev_home_page.dart';
import 'package:module_auth/user/view/login_page.dart';
import 'package:module_auth/user/view/login_password_page.dart';
import 'package:module_auth/user/view/register_page.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/route/route_path.dart';

class AuthModule extends FeatureModule {
  @override
  String get moduleId => 'auth';

  @override
  Bindings? createBinding() => AuthBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.login: (_) => const LoginPage(),
        RoutePath.loginPassword: (_) => const LoginPasswordPage(),
        RoutePath.authDevHome: (_) => const AuthDevHomePage(),
        RoutePath.register: (_) => const RegisterPage(),
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    await AuthSession.register();
    if (context.isStandalone) {
      AuthController.standaloneMode = true;
      createBinding()?.dependencies();
    }
  }
}
