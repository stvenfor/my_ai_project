import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_http/module_http.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_tab_item.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_bluetooth/debug/ble_demo_page.dart';
import 'package:module_rongcloud_im/debug/im_debug_page.dart';
import 'package:module_realtime/debug/realtime_debug_page.dart';
import 'package:module_linking/debug/linking_debug_page.dart';
import 'package:module_settings/deal_invoice/deal_invoice_demo_binding.dart';
import 'package:module_settings/deal_invoice/view/deal_invoice_demo_page.dart';
import 'package:module_settings/deal_invoice/view/deal_invoice_upload_page.dart';
import 'package:module_settings/mine/api/mine_http_config.dart';
import 'package:module_settings/mine/personalized_settings/personalized_settings_controller.dart';
import 'package:module_settings/mine/personalized_settings/view/personalized_settings_page.dart';
import 'package:module_settings/mine/view/mine_http_test_page.dart';
import 'package:module_settings/mine/view/mine_page.dart';
import 'package:module_settings/settings/settings_binding.dart';
import 'package:module_settings/settings/view/dialog_demo_page.dart';
import 'package:module_settings/settings/view/settings_page.dart';

class SettingsModule extends FeatureModule {
  @override
  String get moduleId => 'settings';

  @override
  ModuleTabItem? get mainTab => ModuleTabItem(
        moduleId: moduleId,
        label: '我的',
        icon: CupertinoIcons.person,
        selectedIcon: CupertinoIcons.person_fill,
        pageBuilder: () => const MinePage(showBackButton: false),
        order: 3,
      );

  @override
  Bindings? createBinding() => SettingsBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.mine: (_) => const MinePage(),
        RoutePath.mineHttpTest: (_) => const MineHttpTestPage(),
        RoutePath.personalizedSettings: (_) {
          if (!Get.isRegistered<PersonalizedSettingsController>()) {
            Get.lazyPut(PersonalizedSettingsController.new);
          }
          return const PersonalizedSettingsPage();
        },
        RoutePath.settings: (_) => const SettingsPage(),
        RoutePath.dialogDemo: (_) => const DialogDemoPage(),
        RoutePath.linkingDebug: (_) => const LinkingDebugPage(),
        RoutePath.realtimeDebug: (_) => const RealtimeDebugPage(),
        RoutePath.imDebug: (_) => const ImDebugPage(),
        RoutePath.bluetoothDemo: (_) => const BleDemoPage(),
        RoutePath.dealInvoiceDemo: (_) {
          DealInvoiceDemoBinding().dependencies();
          return const DealInvoiceDemoPage();
        },
        RoutePath.dealInvoiceUpload: (_) {
          DealInvoiceUploadBinding().dependencies();
          return const DealInvoiceUploadPage();
        },
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
