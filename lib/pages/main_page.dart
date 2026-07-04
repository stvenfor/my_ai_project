import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_auth/user/binding/auth_binding.dart';
import 'package:module_auth/user/controller/auth_controller.dart';
import 'package:module_auth/session/auth_session.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_linking/navigation/main_tab_controller.dart';
import 'package:module_music/controller/music_playback_controller.dart';
import 'package:module_music/widgets/music_mini_player_bar.dart';
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
  Worker? _tabSyncWorker;

  @override
  void initState() {
    super.initState();
    ModuleRegistry.ensureBindings();
    _syncTabFromController();
  }

  @override
  void dispose() {
    _tabSyncWorker?.dispose();
    super.dispose();
  }

  void _syncTabFromController() {
    if (!Get.isRegistered<MainTabController>()) return;
    final tabController = Get.find<MainTabController>();
    _currentIndex = tabController.selectedIndex.value;
    _tabSyncWorker?.dispose();
    _tabSyncWorker = ever(tabController.switchRevision, (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = tabController.selectedIndex.value;
      });
    });
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
    if (tab.moduleId == 'chat' && !AuthSession.isLoggedIn) {
      _goLogin();
      return;
    }
    setState(() => _currentIndex = index);
    if (Get.isRegistered<MainTabController>()) {
      Get.find<MainTabController>().selectedIndex.value = index;
    }
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
    final isHomeTab = tabs[safeIndex].moduleId == 'home';

    return ImmersiveAnnotated(
      child: AdaptiveScaffold(
        phone: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: safeIndex,
            children: pages,
          ),
          bottomNavigationBar: _PhoneBottomNavigationBar(
            selectedIndex: safeIndex,
            tabs: tabs,
            showMiniPlayer: isHomeTab,
            onDestinationSelected: (index) => _onTabSelected(index, tabs),
          ),
        ),
        tablet: Scaffold(
          extendBody: true,
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
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    IndexedStack(
                      index: safeIndex,
                      children: pages,
                    ),
                    if (isHomeTab) const MusicMiniPlayerBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 手机底部：迷你播放条（仅首页 Tab）叠在 [NavigationBar] 上方，避免被 Tab 遮挡。
class _PhoneBottomNavigationBar extends StatelessWidget {
  const _PhoneBottomNavigationBar({
    required this.selectedIndex,
    required this.tabs,
    required this.showMiniPlayer,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final List<_TabConfig> tabs;
  final bool showMiniPlayer;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final miniVisible = showMiniPlayer && _hasActiveMusicSession();

      return Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: miniVisible ? 8 : 0,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (miniVisible) const MusicMiniPlayerBar(),
              NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: [
                  for (final tab in tabs)
                    NavigationDestination(
                      icon: Icon(tab.icon),
                      selectedIcon: Icon(tab.selectedIcon),
                      label: tab.label,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  bool _hasActiveMusicSession() {
    if (!Get.isRegistered<MusicPlaybackController>()) return false;
    final playback = Get.find<MusicPlaybackController>();
    playback.playerState.value;
    playback.currentIndex.value;
    return playback.hasActiveSession;
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
