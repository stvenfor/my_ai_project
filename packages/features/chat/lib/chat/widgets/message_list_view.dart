import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_chat/chat/widgets/message_bubble.dart';

class MessageListView extends StatelessWidget {
  const MessageListView({
    super.key,
    required this.peerAvatar,
  });

  final String peerAvatar;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatDetailViewModel>();

    return Obx(() {
      if (controller.isLoading.value && controller.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }

      return ListView.builder(
        controller: controller.scrollController,
        reverse: true,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];
          return MessageBubble(
            key: ValueKey(message.id),
            message: message,
            peerAvatar: peerAvatar,
            onLongPress: () => _showActions(controller, message),
          );
        },
      );
    });
  }

  void _showActions(ChatDetailViewModel controller, MessageModel message) {
    if (message.type == MessageType.time ||
        message.type == MessageType.system) {
      return;
    }

    final actions = <Widget>[];

    if (message.type == MessageType.text) {
      actions.add(
        ListTile(
          leading: const Icon(Icons.copy),
          title: const Text('复制'),
          onTap: () {
            Get.back<void>();
            controller.copyMessage(message);
          },
        ),
      );
    }

    if (message.isSelf && message.canRecall) {
      actions.add(
        ListTile(
          leading: const Icon(Icons.undo),
          title: const Text('撤回'),
          onTap: () {
            Get.back<void>();
            controller.recallMessage(message);
          },
        ),
      );
    }

    actions.add(
      ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.red),
        title: const Text('删除', style: TextStyle(color: Colors.red)),
        onTap: () {
          Get.back<void>();
          controller.deleteMessage(message);
        },
      ),
    );

    if (message.sendStatus == MessageSendStatus.failed) {
      actions.add(
        ListTile(
          leading: const Icon(Icons.refresh),
          title: const Text('重新发送'),
          onTap: () {
            Get.back<void>();
            controller.retrySend(message);
          },
        ),
      );
    }

    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
    );
  }
}
