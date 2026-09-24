import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';

/// Full-screen hold-to-talk HUD (WeChat-style).
class VoiceRecordOverlay extends StatelessWidget {
  const VoiceRecordOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ChatDetailViewModel>();
    return Obx(() {
      if (!vm.isRecordingVoice.value) return const SizedBox.shrink();
      final cancel = vm.voiceCancelIntent.value;
      final seconds = vm.recordDurationSeconds.value;

      return SizedBox.expand(
        child: IgnorePointer(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.45),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: cancel
                          ? const Color(0xFFE53935)
                          : Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cancel
                              ? CupertinoIcons.delete
                              : CupertinoIcons.mic_fill,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${seconds.clamp(0, 60)}"',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    cancel ? '松开手指，取消发送' : '手指上滑，取消发送',
                    style: TextStyle(
                      color: cancel
                          ? const Color(0xFFFF8A80)
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
