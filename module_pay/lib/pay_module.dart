import 'package:flutter/material.dart';
import 'package:module_pay/pay/view/pay_page.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/route/route_path.dart';

class PayModule extends FeatureModule {
  @override
  String get moduleId => 'pay';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.pay: (_) => const PayPage(),
      };
}
