import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_route/module/module_registry.dart';
import 'package:module_sample/route/app_route_container.dart';

class AppPages {
  static List<GetPage<dynamic>> routes() {
    final shell = AppRouteContainer().installShellRouters();
    final moduleRoutes = ModuleRegistry.collectRoutes();
    final merged = <String, WidgetBuilder>{...shell, ...moduleRoutes};

    return merged.entries.map((entry) {
      return GetPage<dynamic>(
        name: entry.key,
        page: () => _RouteHost(builder: entry.value),
      );
    }).toList();
  }
}

class _RouteHost extends StatelessWidget {
  const _RouteHost({required this.builder});

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
