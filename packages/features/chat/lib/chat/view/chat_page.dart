import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/viewmodel/chat_viewmodel.dart';

class ChatPage extends GetView<ChatViewModel> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Obx(() => Text(controller.title.value))),
      body: const Center(child: Text('Chat MVVM 模块')),
    );
  }
}
