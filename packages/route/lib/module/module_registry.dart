import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_tab_item.dart';

/// 已启用模块注册中心，由主工程 [module_manifest.dart] 注入。
class ModuleRegistry {
  ModuleRegistry._();

  static final List<FeatureModule> _modules = [];
  static bool _bootstrapped = false;

  static List<FeatureModule> get modules => List.unmodifiable(_modules);

  static void registerAll(List<FeatureModule> modules) {
    _modules
      ..clear()
      ..addAll(modules);
    _bootstrapped = false;
  }

  static Future<void> bootstrap(ModuleHostContext context) async {
    if (_bootstrapped) return;
    for (final module in _modules) {
      await module.onRegister(context);
    }
    _bootstrapped = true;
  }

  static Map<String, WidgetBuilder> collectRoutes() {
    final routes = <String, WidgetBuilder>{};
    for (final module in _modules) {
      routes.addAll(module.routes());
    }
    return routes;
  }

  static List<ModuleTabItem> collectMainTabs() {
    final tabs = _modules
        .map((module) => module.mainTab)
        .whereType<ModuleTabItem>()
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return tabs;
  }

  static List<Bindings> collectBindings() {
    return _modules
        .map((module) => module.createBinding())
        .whereType<Bindings>()
        .toList();
  }

  static FeatureModule? findById(String moduleId) {
    for (final module in _modules) {
      if (module.moduleId == moduleId) return module;
    }
    return null;
  }
}
