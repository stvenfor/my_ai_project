import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/bindings/chat_detail_binding.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/view/chat_detail_page.dart';
import 'package:module_chat/chat/viewmodel/chat_viewmodel.dart';
import 'package:module_chat/chat/widgets/conversation_list_item.dart';
import 'package:module_common_ui/module_common_ui.dart';

class ChatPage extends GetView<ChatViewModel> {
  const ChatPage({super.key});

  void _openConversation(ConversationModel conversation) {
    Get.to<void>(
      () => ChatDetailPage(conversation: conversation),
      binding: ChatDetailBinding(conversation),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    )?.then((_) => controller.refreshConversations());
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      layout: AppPageLayout.standard,
      backgroundColor: const Color(0xFFEDEDED),
      navBar: AppNavBar(
        title: '微信',
        style: AppNavBarStyle.solid,
        backgroundColor: const Color(0xFFEDEDED),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (controller.errorMessage.value != null &&
            controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage.value!),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.refreshConversations,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshConversations,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.conversations.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final item = controller.conversations[index];
              return ConversationListItem(
                conversation: item,
                onTap: () => _openConversation(item),
              );
            },
          ),
        );
      }),
    );
  }
}
