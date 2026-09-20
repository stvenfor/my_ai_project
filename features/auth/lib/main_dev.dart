import 'package:flutter/material.dart';
import 'package:module_auth/auth_module.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:wys_router/src/module/module_standalone_config.dart';
import 'package:wys_router/src/module/module_standalone_runner.dart';

/// Auth 独立运行占位路由（非产品登录门；登录仅经壳工程）。
const _standalonePlaceholderRoute = '/auth/standalone_placeholder';

Future<void> main() => ModuleStandaloneRunner.run(
      AuthModule(),
      config: ModuleStandaloneConfig(
        initialRoute: _standalonePlaceholderRoute,
        extraRoutes: {
          _standalonePlaceholderRoute: (_) =>
              const _AuthStandalonePlaceholderPage(),
        },
        onSetup: () async {
          await UiKitInitializer.initialize();
        },
        innerAppBuilder: UiKitInitializer.wrapChild,
        navigatorObservers: UiKitInitializer.navigatorObservers,
      ),
    );

/// 说明页：独立运行不再提供登录/注册闭环（ADR 0007）。
class _AuthStandalonePlaceholderPage extends StatelessWidget {
  const _AuthStandalonePlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: 'Auth 独立运行'),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '登录门仅在壳工程',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text(
              'auth 模块独立运行（main_dev / run_module.sh auth）'
              '不再提供登录或注册入口。\n\n'
              '请通过壳工程打开 LoginPage / RegisterPage 完成认证并写入会话。',
              style: TextStyle(fontSize: 15, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
