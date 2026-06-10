import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_tab_item.dart';

/// 功能模块统一入口。每个 module_* 提供一份实现，主工程按需注册。
abstract class FeatureModule {
  String get moduleId;

  /// 模块路由表（路径 → 页面构建器）。
  Map<String, WidgetBuilder> routes();

  /// 若该模块需要出现在主 Tab，返回 Tab 描述；否则返回 null。
  ModuleTabItem? get mainTab => null;

  /// GetX 依赖注入，页面进入前注册 ViewModel / Repository。
  Bindings? createBinding() => null;

  /// 模块初始化：HTTP、缓存等（独立运行时必须实现）。
  Future<void> onRegister(ModuleHostContext context) async {}
}
