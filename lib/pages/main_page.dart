import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_route/module/module_registry.dart';
import 'package:module_sample/l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<_TabConfig> get _tabs {
    final l10n = AppLocalizations.of(context);
    return ModuleRegistry.collectMainTabs().map((tab) {
      return _TabConfig(
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

    return AdaptiveScaffold(
      phone: Scaffold(
        body: IndexedStack(
          index: safeIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
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
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: safeIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
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
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
}
