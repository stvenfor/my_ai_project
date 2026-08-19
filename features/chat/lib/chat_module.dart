import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/bindings/chat_detail_binding.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/view/chat_detail_page.dart';
import 'package:module_chat/chat/view/chat_page.dart';
import 'package:module_chat/chat/viewmodel/chat_viewmodel.dart';
import 'package:module_core/model/im/conversation_type.dart';
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
        icon: CupertinoIcons.chat_bubble,
        selectedIcon: CupertinoIcons.chat_bubble_fill,
        pageBuilder: () => const ChatPage(),
        order: 1,
      );

  @override
  Bindings? createBinding() => ChatBinding();

  @override
  Map<String, WidgetBuilder> routes() => {
        RoutePath.chat: (_) => const ChatPage(),
        RoutePath.chatDetail: (_) {
          final conversation = _resolveConversation(Get.arguments);
          if (conversation == null) {
            return const Scaffold(
              body: Center(child: Text('缺少会话参数')),
            );
          }
          ChatDetailBinding(conversation).dependencies();
          return ChatDetailPage(conversation: conversation);
        },
      };

  @override
  Future<void> onRegister(ModuleHostContext context) async {
    if (context.isStandalone) ChatBinding().dependencies();
  }
}

ConversationModel? _resolveConversation(Object? args) {
  if (args is ConversationModel) return args;
  if (args is Map) {
    final map = Map<String, dynamic>.from(args);
    final type = map['type']?.toString() == 'group'
        ? ConversationType.group
        : ConversationType.private;
    final targetId =
        map['targetId']?.toString() ?? map['peerId']?.toString() ?? 'peer_mock';
    final storageId = type == ConversationType.private
        ? 'private_$targetId'
        : 'group_$targetId';
    return ConversationModel(
      id: map['id']?.toString() ?? storageId,
      type: type,
      targetId: targetId,
      title: map['peerName']?.toString() ?? map['title']?.toString() ?? 'Mock',
      portraitUrl: map['peerAvatar']?.toString() ?? map['portraitUrl']?.toString() ?? '',
      lastMessage: map['lastMessage']?.toString() ?? '',
      lastMessageTime: DateTime.tryParse(map['lastMessageTime']?.toString() ?? '') ??
          DateTime.now(),
      isOnline: map['isOnline'] == true,
      unreadCount: int.tryParse(map['unreadCount']?.toString() ?? '0') ?? 0,
    );
  }
  return null;
}
