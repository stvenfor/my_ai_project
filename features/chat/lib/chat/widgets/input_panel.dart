import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/theme/chat_theme.dart';
import 'package:module_chat/chat/viewmodel/chat_detail_viewmodel.dart';
import 'package:module_chat/chat/widgets/emoji_panel.dart';
import 'package:module_chat/chat/widgets/more_panel.dart';
import 'package:module_utils/module_utils.dart';

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
        decoration: BoxDecoration(
          color: ChatTheme.surface,
          border: Border(
            top: BorderSide(color: ChatTheme.separator, width: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PanelIconButton(
                    icon: isVoiceMode
                        ? CupertinoIcons.keyboard
                        : CupertinoIcons.mic_fill,
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
                      icon: CupertinoIcons.plus_circle_fill,
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
          hintText: '发消息…',
          hintStyle: ChatTheme.body.copyWith(color: ChatTheme.labelTertiary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class _VoiceHoldButton extends StatefulWidget {
  const _VoiceHoldButton({required this.controller});

  final ChatDetailViewModel controller;

  @override
  State<_VoiceHoldButton> createState() => _VoiceHoldButtonState();
}

class _VoiceHoldButtonState extends State<_VoiceHoldButton> {
  int? _activePointer;
  double _startY = 0;
  static const _cancelSlop = 72.0;

  ChatDetailViewModel get _vm => widget.controller;

  void _attachGlobalRoute(int pointer) {
    GestureBinding.instance.pointerRouter.addRoute(pointer, _onGlobalPointer);
  }

  void _detachGlobalRoute(int pointer) {
    GestureBinding.instance.pointerRouter.removeRoute(pointer, _onGlobalPointer);
  }

  void _onGlobalPointer(PointerEvent event) {
    if (event.pointer != _activePointer) return;
    if (event is PointerMoveEvent) {
      final dy = _startY - event.position.dy;
      _vm.setVoiceCancelIntent(dy >= _cancelSlop);
      return;
    }
    if (event is PointerUpEvent) {
      _finish(send: !_vm.voiceCancelIntent.value);
      return;
    }
    if (event is PointerCancelEvent) {
      // Ignore cancel while actively holding — rebuilds used to abort every take.
      // Real system cancels are rare; user can still slide-up to discard.
      LogUtils.w('[VoiceHold] pointer cancel ignored (pointer=${event.pointer})');
    }
  }

  void _onDown(PointerDownEvent e) {
    if (_activePointer != null) return;
    _activePointer = e.pointer;
    _startY = e.position.dy;
    _vm.setVoiceCancelIntent(false);
    _attachGlobalRoute(e.pointer);
    unawaited(_vm.beginVoicePress());
  }

  void _finish({required bool send}) {
    final pointer = _activePointer;
    if (pointer == null) return;
    _activePointer = null;
    _detachGlobalRoute(pointer);
    unawaited(_vm.endVoicePress(send: send));
  }

  @override
  void dispose() {
    final pointer = _activePointer;
    if (pointer != null) {
      _detachGlobalRoute(pointer);
      _activePointer = null;
      unawaited(_vm.endVoicePress(send: false));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep Listener OUTSIDE Obx — rebuilding Listener on record state change
    // was delivering PointerCancel and aborting every take.
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onDown,
      child: Obx(() {
        final recording = _vm.isRecordingVoice.value;
        final cancel = _vm.voiceCancelIntent.value;
        final seconds = _vm.recordDurationSeconds.value;

        final bg = !recording
            ? ChatTheme.fillSecondary
            : (cancel ? const Color(0xFFE53935) : ChatTheme.accent);
        final label = !recording
            ? '按住 说话'
            : (cancel ? '松开 取消' : '松开发送 ${seconds}s');

        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(ChatTheme.inputRadius),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: recording ? Colors.white : ChatTheme.labelPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }
}

