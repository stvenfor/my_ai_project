import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_community/community/view/community_page.dart';
import 'package:module_community/community/view/publish_page.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_tab_item.dart';
import 'package:module_route/route/route_path.dart';

class CommunityModule extends FeatureModule {
  @override
  String get moduleId => 'community';

  @override
  ModuleTabItem? get mainTab => ModuleTabItem(
        moduleId: moduleId,
        label: '社区',
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups_rounded,
        pageBuilder: () => const CommunityPage(),
        order: 2,
      );

  @override
  Bindings? createBinding() => CommunityBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.community: (_) => const CommunityPage(),
        RoutePath.communityPublish: (_) => const PublishPage(),
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    if (context.isStandalone) CommunityBinding().dependencies();
  }
}
