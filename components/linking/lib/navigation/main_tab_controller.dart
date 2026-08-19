import 'package:get/get.dart';
import 'package:module_route/module/module_registry.dart';

/// 主 Tab 切换控制器（Deeplink / Push 先切 Tab 再 push）。
class MainTabController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  final RxInt switchRevision = 0.obs;

  int? indexForModule(String moduleId) {
    final tabs = ModuleRegistry.collectMainTabs();
    for (var i = 0; i < tabs.length; i++) {
      if (tabs[i].moduleId == moduleId) return i;
    }
    return null;
  }

  Future<bool> switchToModule(String moduleId) async {
    final index = indexForModule(moduleId);
    if (index == null) return false;
    selectedIndex.value = index;
    switchRevision.value++;
    return true;
  }
}
