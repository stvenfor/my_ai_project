import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';

class EmojiPanel extends StatelessWidget {
  const EmojiPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatDetailViewModel>();

    return Container(
      height: 220,
      color: ChatTheme.background,
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: ChatDetailViewModel.emojiList.length,
        itemBuilder: (context, index) {
          final emoji = ChatDetailViewModel.emojiList[index];
          return InkWell(
            onTap: () => controller.appendEmoji(emoji),
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    );
  }
}
