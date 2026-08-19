import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/message_model.dart';
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
    final width = 80.0 + duration * 3;

    return Obx(() {
      final isPlaying = controller.playingVoiceId.value == message.id;
      final frame = controller.voiceAnimFrame.value;
      return GestureDetector(
        onTap: () => controller.toggleVoicePlay(message),
        child: Container(
          width: width.clamp(80, 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment:
                isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isSelf) _VoiceWave(isPlaying: isPlaying, frame: frame),
              if (!isSelf) const SizedBox(width: 8),
              Text(
                '${duration}"',
                style: TextStyle(
                  fontSize: 14,
                  color: isSelf ? Colors.black87 : Colors.black87,
                ),
              ),
              if (isSelf) const SizedBox(width: 8),
              if (isSelf) _VoiceWave(isPlaying: isPlaying, frame: frame),
            ],
          ),
        ),
      );
    });
  }
}

class _VoiceWave extends StatelessWidget {
  const _VoiceWave({required this.isPlaying, required this.frame});

  final bool isPlaying;
  final int frame;

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
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: h,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
