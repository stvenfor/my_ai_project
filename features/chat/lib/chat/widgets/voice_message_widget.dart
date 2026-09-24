import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';

class VoiceMessageWidget extends StatelessWidget {
  const VoiceMessageWidget({
    super.key,
    required this.message,
    required this.isSelf,
  });

  final MessageModel message;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatDetailViewModel>();
    final duration = message.voiceDurationSeconds.clamp(1, 60);
    final width = 88.0 + duration * 3.2;
    final fg = isSelf ? ChatTheme.selfBubbleText.color! : ChatTheme.labelPrimary;

    return Obx(() {
      final isPlaying = controller.playingVoiceId.value == message.id;
      final frame = controller.voiceAnimFrame.value;
      return GestureDetector(
        onTap: () => controller.toggleVoicePlay(message),
        child: SizedBox(
          width: width.clamp(88, 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisAlignment:
                  isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isSelf) _VoiceWave(isPlaying: isPlaying, frame: frame, color: fg),
                if (!isSelf) const SizedBox(width: 8),
                Text(
                  '${duration}"',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
                if (isSelf) const SizedBox(width: 8),
                if (isSelf) _VoiceWave(isPlaying: isPlaying, frame: frame, color: fg),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _VoiceWave extends StatelessWidget {
  const _VoiceWave({
    required this.isPlaying,
    required this.frame,
    required this.color,
  });

  final bool isPlaying;
  final int frame;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final heights = isPlaying
        ? [
            8.0 + frame * 2,
            14.0 + (frame + 1) % 3 * 2,
            10.0 + frame,
          ]
        : [8.0, 14.0, 10.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: heights
          .map(
            (h) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: h,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
