import 'package:flutter/material.dart';
import 'package:module_sample/l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/module/module_registry.dart';
import 'package:module_route/route/route_path.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeByAuth());
  }

  void _routeByAuth() {
    // 游客模式：无论是否登录均进入主页，社区 Tab 单独拦截登录。
    ModuleRegistry.ensureBindings();
    Get.offNamed(RoutePath.main);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppPageScaffold(
      layout: AppPageLayout.edgeToEdge,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.splashLoading),
          ],
        ),
      ),
    );
  }
}
