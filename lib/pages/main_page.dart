import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/core.dart';
import 'package:module_route/module/module_registry.dart';
import 'package:module_route/route/route_path.dart';
import 'package:module_sample/l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  Future<void> _logout() async {
    await AuthSession.logout();
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    Get.offAllNamed(RoutePath.login);
  }

  void _goLogin() {
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    Get.toNamed(RoutePath.login);
  }

  void _onTabSelected(int index, List<_TabConfig> tabs) {
    final tab = tabs[index];
    if (tab.moduleId == 'community' && !AuthSession.isLoggedIn) {
      _goLogin();
      return;
    }
    setState(() => _currentIndex = index);
  }

  List<_TabConfig> get _tabs {
    final l10n = AppLocalizations.of(context);
    return ModuleRegistry.collectMainTabs().map((tab) {
      return _TabConfig(
        moduleId: tab.moduleId,
        label: _resolveLabel(tab.moduleId, tab.label, l10n),
        icon: tab.icon,
        selectedIcon: tab.selectedIcon,
        page: tab.pageBuilder(),
      );
    }).toList();
  }

  String _resolveLabel(String moduleId, String fallback, AppLocalizations? l10n) {
    if (l10n == null) return fallback;
    return switch (moduleId) {
      'home' => l10n.tabHome,
      'chat' => l10n.tabChat,
      'community' => l10n.tabCommunity,
      'settings' => l10n.tabMine,
      _ => fallback,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;
    if (tabs.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('未启用任何 Tab 模块，请检查 module_manifest.dart')),
      );
    }

    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);
    final pages = tabs.map((tab) => tab.page).toList();

    final userService = Get.find<UserService>();

    return AdaptiveScaffold(
      phone: Scaffold(
        appBar: AppBar(
          title: Text(tabs[safeIndex].label),
          actions: [
            Obx(() {
              final loggedIn = userService.isLoggedIn;
              return IconButton(
                onPressed: loggedIn ? _logout : _goLogin,
                icon: Icon(loggedIn ? Icons.logout_rounded : Icons.login_rounded),
                tooltip: loggedIn ? '退出登录' : '登录',
              );
            }),
          ],
        ),
        body: IndexedStack(
          index: safeIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (index) => _onTabSelected(index, tabs),
          destinations: [
            for (final tab in tabs)
              NavigationDestination(
                icon: Icon(tab.icon),
                selectedIcon: Icon(tab.selectedIcon),
                label: tab.label,
              ),
          ],
        ),
      ),
      tablet: Scaffold(
        appBar: AppBar(
          title: Text(tabs[safeIndex].label),
          actions: [
            Obx(() {
              final loggedIn = userService.isLoggedIn;
              return IconButton(
                onPressed: loggedIn ? _logout : _goLogin,
                icon: Icon(loggedIn ? Icons.logout_rounded : Icons.login_rounded),
                tooltip: loggedIn ? '退出登录' : '登录',
              );
            }),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: safeIndex,
              onDestinationSelected: (index) => _onTabSelected(index, tabs),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final tab in tabs)
                  NavigationRailDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: Text(tab.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(
                index: safeIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabConfig {
  const _TabConfig({
    required this.moduleId,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String moduleId;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}
