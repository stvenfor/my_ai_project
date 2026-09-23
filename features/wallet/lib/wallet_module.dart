import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_wallet/wallet/controller/wallet_controller.dart';
import 'package:module_wallet/wallet/view/wallet_page.dart';
import 'package:wys_router/src/module/feature_module.dart';
import 'package:wys_router/src/route/route_path.dart';

class WalletModule extends FeatureModule {
  @override
  String get moduleId => 'wallet';

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.wallet: (_) {
          if (Get.isRegistered<WalletController>()) {
            Get.delete<WalletController>(force: true);
          }
          Get.put(WalletController());
          return const WalletPage();
        },
      };
}
