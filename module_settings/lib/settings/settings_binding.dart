import 'package:get/get.dart';
import 'package:module_settings/mine/viewmodel/mine_http_test_viewmodel.dart';
import 'package:module_settings/mine/viewmodel/mine_viewmodel.dart';
import 'package:module_settings/settings/viewmodel/settings_viewmodel.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MineViewModel>(MineViewModel.new);
    Get.lazyPut<SettingsViewModel>(SettingsViewModel.new);
    Get.lazyPut<MineHttpTestViewModel>(
      MineHttpTestViewModel.new,
      fenix: true,
    );
  }
}
