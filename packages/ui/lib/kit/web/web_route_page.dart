import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/kit/web/app_web_view_page.dart';
import 'package:module_core/core.dart';
import 'package:module_route/route/route_path.dart';

/// Get 命名路由入口：从 [Get.arguments] 读取 [WebPageConfig] 并交给 [AppWebViewPage]。
class WebRoutePage extends StatelessWidget {
  const WebRoutePage({super.key});

  static WebPageConfig? resolveConfig() {
    final args = Get.arguments;
    if (args is WebPageConfig) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final config = resolveConfig();
    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('网页')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('缺少 WebPageConfig 参数'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Get.back<void>(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }
    return AppWebViewPage(config: config);
  }
}

/// 壳工程 / 独立运行需合并的全局 Web 路由表。
class WebKitRoutes {
  WebKitRoutes._();

  static Map<String, WidgetBuilder> routes() => {
        RoutePath.web: (_) => const WebRoutePage(),
      };
}
