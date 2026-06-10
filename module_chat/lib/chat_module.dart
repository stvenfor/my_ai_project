import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/view/chat_page.dart';
import 'package:module_chat/chat/viewmodel/chat_viewmodel.dart';
import 'package:module_route/module/feature_module.dart';
import 'package:module_route/module/module_host_context.dart';
import 'package:module_route/module/module_tab_item.dart';
import 'package:module_route/route/route_path.dart';

class ChatModule extends FeatureModule {
  @override
  String get moduleId => 'chat';

  @override
  ModuleTabItem? get mainTab => ModuleTabItem(
        moduleId: moduleId,
        label: '聊天',
        icon: Icons.chat_bubble_outline_rounded,
        selectedIcon: Icons.chat_bubble_rounded,
        pageBuilder: () => const ChatPage(),
        order: 1,
      );

  @override
  Bindings? createBinding() => ChatBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.chat: (_) => const ChatPage(),
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    if (context.isStandalone) ChatBinding().dependencies();
  }
}
