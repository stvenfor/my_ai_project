import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/chat_avatar_urls.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_chat/chat/widgets/image_message_widget.dart';
import 'package:module_chat/chat/widgets/time_system_message_widget.dart';
import 'package:module_chat/chat/widgets/voice_message_widget.dart';
import 'package:module_utils/module_utils.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.peerAvatar,
    required this.onLongPress,
  });

  final MessageModel message;
  final String peerAvatar;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.time) {
      return TimeMessageWidget(label: message.content);
    }
    if (message.type == MessageType.system) {
      return SystemMessageWidget(text: message.content);
    }

    final controller = Get.find<ChatDetailViewModel>();
    final isSelf = message.isSelf;
    final isMedia = message.type == MessageType.image ||
        message.type == MessageType.voice;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(isSelf ? (1 - value) * 12 : (value - 1) * 12, 0),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment:
              isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSelf) ...[
              CacheImageUtils.circle(peerAvatar, size: 36),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isSelf ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: onLongPress,
                    child: Container(
                      padding: isMedia
                          ? (message.type == MessageType.voice
                              ? EdgeInsets.zero
                              : const EdgeInsets.all(3))
                          : const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                      decoration: BoxDecoration(
                        color:
                            isSelf ? ChatTheme.selfBubble : ChatTheme.peerBubble,
                        borderRadius: ChatTheme.bubbleRadiusFor(isSelf: isSelf),
                        border: isSelf
                            ? null
                            : Border.all(
                                color: ChatTheme.separator,
                                width: 0.5,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildContent(isSelf),
                    ),
                  ),
                  Obx(() {
                    final index = controller.messages
                        .indexWhere((m) => m.id == message.id);
                    final current =
                        index >= 0 ? controller.messages[index] : message;
                    final label = controller.readStatusLabel(current);
                    if (label.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                      child: Text(
                        label,
                        style: ChatTheme.caption.copyWith(
                          fontSize: 11,
                          color: current.sendStatus == MessageSendStatus.failed
                              ? ChatTheme.unreadBadge
                              : ChatTheme.labelTertiary,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (isSelf) ...[
              const SizedBox(width: 8),
              CacheImageUtils.circle(ChatAvatarUrls.self, size: 36),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isSelf) {
    return switch (message.type) {
      MessageType.text => Text(
          message.content,
          style: isSelf ? ChatTheme.selfBubbleText : ChatTheme.peerBubbleText,
        ),
      MessageType.image => ImageMessageWidget(
          url: message.content,
        ),
      MessageType.voice => VoiceMessageWidget(
          message: message,
          isSelf: message.isSelf,
        ),
      MessageType.custom => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.customPayload['title']?.toString() ??
                    message.customType ??
                    '自定义消息',
                style: ChatTheme.headline.copyWith(fontSize: 15),
              ),
              if (message.customPayload['subtitle'] != null)
                Text(
                  message.customPayload['subtitle'].toString(),
                  style: ChatTheme.caption,
                ),
            ],
          ),
        ),
      MessageType.time || MessageType.system => const SizedBox.shrink(),
    };
  }
}
