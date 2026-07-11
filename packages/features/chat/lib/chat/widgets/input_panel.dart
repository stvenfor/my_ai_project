import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
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
      final hasText = controller.inputText.value.trim().isNotEmpty;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        color: ChatTheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                8,
                8,
                8,
                8 + (bottomInset > 0 ? 0 : 0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PanelIconButton(
                    icon: isVoiceMode
                        ? CupertinoIcons.keyboard
                        : CupertinoIcons.mic,
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
                  if (!isVoiceMode && !hasText) ...[
                    _PanelIconButton(
                      icon: CupertinoIcons.smiley,
                      onPressed: controller.toggleEmojiPanel,
                    ),
                    _PanelIconButton(
                      icon: CupertinoIcons.plus,
                      onPressed: controller.toggleMorePanel,
                    ),
                  ],
                  if (!isVoiceMode && hasText)
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
            if (bottomInset == 0)
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      );
    });
  }
}

class _PanelIconButton extends StatelessWidget {
  const _PanelIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        icon: Icon(icon, color: ChatTheme.labelSecondary, size: 24),
        onPressed: onPressed,
      ),
    );
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
        color: ChatTheme.fillSecondary,
        borderRadius: BorderRadius.circular(ChatTheme.inputRadius),
        border: Border.all(color: ChatTheme.separator, width: 0.5),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        maxLines: 4,
        minLines: 1,
        style: ChatTheme.body,
        textInputAction: TextInputAction.send,
        decoration: InputDecoration(
          hintText: '信息',
          hintStyle: ChatTheme.body.copyWith(color: ChatTheme.labelTertiary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: SizedBox(
        width: 36,
        height: 36,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: ChatTheme.accent,
          borderRadius: BorderRadius.circular(18),
          onPressed: onTap,
          child: const Icon(
            CupertinoIcons.arrow_up,
            color: Colors.white,
            size: 18,
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
            color: recording ? ChatTheme.accent : ChatTheme.fillSecondary,
            borderRadius: BorderRadius.circular(ChatTheme.inputRadius),
            border: Border.all(
              color: recording ? ChatTheme.accent : ChatTheme.separator,
              width: 0.5,
            ),
          ),
          child: Text(
            recording ? '松开发送 ${seconds}s' : '按住 说话',
            style: TextStyle(
              color: recording ? Colors.white : ChatTheme.labelPrimary,
              fontSize: 15,
            ),
          ),
        ),
      );
    });
  }
}
