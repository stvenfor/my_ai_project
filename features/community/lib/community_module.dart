import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:module_community/community/view/community_page.dart';
import 'package:module_community/community/view/community_search_page.dart';
import 'package:module_community/community/view/publish_page.dart';
import 'package:module_community/community/viewmodel/community_viewmodel.dart';
import 'package:wys_router/src/module/feature_module.dart';
import 'package:wys_router/src/module/module_host_context.dart';
import 'package:wys_router/src/module/module_tab_item.dart';
import 'package:wys_router/src/route/route_path.dart';

class CommunityModule extends FeatureModule {
  @override
  String get moduleId => 'community';

  @override
  ModuleTabItem? get mainTab => ModuleTabItem(
        moduleId: moduleId,
        label: '社区',
        icon: CupertinoIcons.person_2,
        selectedIcon: CupertinoIcons.person_2_fill,
        pageBuilder: () => const CommunityPage(),
        order: 2,
      );

  @override
  Bindings? createBinding() => CommunityBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.community: (_) => const CommunityPage(),
        RoutePath.communityPublish: (_) => const PublishPage(),
        RoutePath.communitySearch: (_) => const CommunitySearchPage(),
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    if (context.isStandalone) CommunityBinding().dependencies();
  }
}
