import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_chat/chat/widgets/chat_detail_app_bar.dart';
import 'package:module_chat/chat/widgets/input_panel.dart';
import 'package:module_chat/chat/widgets/message_list_view.dart';
import 'package:module_common_ui/module_common_ui.dart';

class ChatDetailPage extends GetView<ChatDetailViewModel> {
  ChatDetailPage({super.key, ConversationModel? conversation})
      : conversation = conversation ?? Get.arguments as ConversationModel;

  final ConversationModel conversation;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.standard,
      backgroundColor: const Color(0xFFEDEDED),
      resizeToAvoidBottomInset: true,
      navBar: ChatDetailAppBar(
        conversation: conversation,
        onBack: () => Get.back<void>(),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageListView(peerAvatar: conversation.peerAvatar),
          ),
          const InputPanel(),
        ],
      ),
    );
  }
}
