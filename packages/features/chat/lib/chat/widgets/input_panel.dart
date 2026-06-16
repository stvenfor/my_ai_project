import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_chat/chat/widgets/emoji_panel.dart';
import 'package:module_chat/chat/widgets/more_panel.dart';

class InputPanel extends StatefulWidget {
  const InputPanel({super.key});

  @override
  State<InputPanel> createState() => _InputPanelState();
}

class _InputPanelState extends State<InputPanel> {
  late final TextEditingController _textController;
  Worker? _inputSyncWorker;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    final vm = Get.find<ChatDetailViewModel>();
    _inputSyncWorker = ever(vm.inputText, (text) {
      if (_textController.text != text) {
        _textController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _inputSyncWorker?.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatDetailViewModel>();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Obx(() {
      final mode = controller.inputPanelMode.value;
      final isVoiceMode = mode == InputPanelMode.voice;
      final showEmoji = mode == InputPanelMode.emoji;
      final showMore = mode == InputPanelMode.more;
      final panelHeight = (showEmoji || showMore) ? 220.0 : 0.0;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 0),
        color: const Color(0xFFF7F7F7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      isVoiceMode ? Icons.keyboard : Icons.mic_none,
                      color: Colors.black54,
                    ),
                    onPressed: controller.toggleVoiceInput,
                  ),
                  Expanded(
                    child: isVoiceMode
                        ? _VoiceHoldButton(controller: controller)
                        : _TextInput(
                            controller: _textController,
                            onChanged: controller.updateInput,
                            onSubmitted: (_) => controller.sendTextMessage(),
                          ),
                  ),
                  if (!isVoiceMode && controller.inputText.value.trim().isEmpty)
                    IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined,
                          color: Colors.black54),
                      onPressed: controller.toggleEmojiPanel,
                    ),
                  if (!isVoiceMode && controller.inputText.value.trim().isEmpty)
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: Colors.black54),
                      onPressed: controller.toggleMorePanel,
                    ),
                  if (!isVoiceMode &&
                      controller.inputText.value.trim().isNotEmpty)
                    _SendButton(onTap: controller.sendTextMessage),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: bottomInset > 0 ? 0 : panelHeight,
              child: showEmoji
                  ? const EmojiPanel()
                  : showMore
                      ? const MorePanel()
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        maxLines: 4,
        minLines: 1,
        textInputAction: TextInputAction.send,
        decoration: const InputDecoration(
          hintText: '输入消息...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 150),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4),
        child: Material(
          color: const Color(0xFF07C160),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                '发送',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceHoldButton extends StatelessWidget {
  const _VoiceHoldButton({required this.controller});

  final ChatDetailViewModel controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recording = controller.isRecordingVoice.value;
      final seconds = controller.recordDurationSeconds.value;

      return GestureDetector(
        onLongPressStart: (_) => controller.startRecordVoice(),
        onLongPressEnd: (_) => controller.stopRecordVoice(send: true),
        onLongPressCancel: () => controller.stopRecordVoice(send: false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: recording ? const Color(0xFF07C160) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: recording ? const Color(0xFF07C160) : const Color(0xFFE0E0E0),
            ),
          ),
          child: Text(
            recording ? '松开发送 ${seconds}s' : '按住 说话',
            style: TextStyle(
              color: recording ? Colors.white : Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
      );
    });
  }
}
