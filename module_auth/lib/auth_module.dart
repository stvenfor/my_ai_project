import 'package:flutter/material.dart';
import 'package:module_auth/user/view/login_page.dart';
import 'package:module_auth/user/view/register_page.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';

class AuthModule extends FeatureModule {
  @override
  String get moduleId => 'auth';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.login: (_) => const LoginPage(),
        RoutePath.register: (_) => const RegisterPage(),
      };
}
