import 'package:flutter/material.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

class ChatDetailAppBar extends StatelessWidget {
  const ChatDetailAppBar({
    super.key,
    required this.conversation,
    required this.onBack,
  });

  final ConversationModel conversation;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppNavBar(
      showBackButton: true,
      onBack: onBack,
      style: AppNavBarStyle.solid,
      backgroundColor: const Color(0xFFEDEDED),
      titleWidget: Row(
        children: [
          CacheImageUtils.circle(conversation.peerAvatar, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  conversation.peerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  conversation.isOnline ? '在线' : '离线',
                  style: TextStyle(
                    fontSize: 12,
                    color: conversation.isOnline
                        ? const Color(0xFF07C160)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {},
        ),
      ],
    );
  }
}
