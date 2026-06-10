import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_http/module_http.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_tab_item.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_settings/mine/api/mine_http_config.dart';
import 'package:module_settings/mine/view/mine_http_test_page.dart';
import 'package:module_settings/mine/view/mine_page.dart';
import 'package:module_settings/settings/settings_binding.dart';
import 'package:module_settings/settings/view/settings_page.dart';

class SettingsModule extends FeatureModule {
  @override
  String get moduleId => 'settings';

  @override
  ModuleTabItem? get mainTab => ModuleTabItem(
        moduleId: moduleId,
        label: '我的',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        pageBuilder: () => const MinePage(showBackButton: false),
        order: 3,
      );

  @override
  Bindings? createBinding() => SettingsBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.mine: (_) => const MinePage(),
        RoutePath.mineHttpTest: (_) => const MineHttpTestPage(),
        RoutePath.settings: (_) => const SettingsPage(),
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    if (context.isStandalone || !HttpManager.instance.isInitialized) {
      MineHttpConfig.init(
        enableLog: context.enableHttpLog,
        maxRetries: context.httpMaxRetries,
      );
    }
    if (context.isStandalone) {
      SettingsBinding().dependencies();
    }
  }
}
