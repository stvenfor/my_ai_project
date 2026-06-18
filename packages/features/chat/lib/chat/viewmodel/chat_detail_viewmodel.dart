import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/chat_custom_message_types.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/repository/chat_repository.dart';
import 'package:module_chat/chat/repository/im_chat_repository.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_core/model/im/conversation_ref.dart';
import 'package:module_utils/module_utils.dart';

enum InputPanelMode { text, voice, emoji, more }

class ChatDetailViewModel extends GetxController {
  ChatDetailViewModel({
    required this.conversation,
    ChatRepository? repository,
  }) : _repository = repository ?? resolveChatRepository();

  final ConversationModel conversation;
  final ChatRepository _repository;

  ConversationRef get _ref => conversation.ref;

  final messages = <MessageModel>[].obs;
  final inputText = ''.obs;
  final inputPanelMode = InputPanelMode.text.obs;
  final isLoading = false.obs;
  final playingVoiceId = RxnString();
  final isRecordingVoice = false.obs;
  final recordDurationSeconds = 0.obs;

  final scrollController = ScrollController();
  StreamSubscription<List<MessageModel>>? _msgSub;
  Timer? _voicePlayTimer;
  Timer? _recordTimer;
  int _voiceAnimFrame = 0;
  final voiceAnimFrame = 0.obs;

  static const recallWindowMinutes = 3;
  static const emojiList = [
    '😀', '😂', '🥰', '😎', '🤔', '👍', '🙏', '🎉',
    '❤️', '🔥', '👋', '😭', '🤣', '😊', '🥳', '💪',
  ];

  @override
  void onInit() {
    super.onInit();
    _msgSub = _repository.watchMessages(_ref).listen((list) {
      messages.assignAll(list);
      _scrollToLatest();
    });
    _markRead();
  }

  Future<void> _markRead() async {
    try {
      await _repository.markConversationRead(_ref);
    } catch (e) {
      LogUtils.w('[ChatDetail] markRead failed: $e');
    }
  }

  void updateInput(String value) => inputText.value = value;

  void toggleVoiceInput() {
    inputPanelMode.value =
        inputPanelMode.value == InputPanelMode.voice ? InputPanelMode.text : InputPanelMode.voice;
  }

  void toggleEmojiPanel() {
    inputPanelMode.value = inputPanelMode.value == InputPanelMode.emoji
        ? InputPanelMode.text
        : InputPanelMode.emoji;
  }

  void toggleMorePanel() {
    inputPanelMode.value = inputPanelMode.value == InputPanelMode.more
        ? InputPanelMode.text
        : InputPanelMode.more;
  }

  void appendEmoji(String emoji) {
    inputText.value = '${inputText.value}$emoji';
  }

  bool _shouldInsertTimeDivider(DateTime createdAt) {
    if (messages.isEmpty) return true;
    final latest = messages.first;
    if (latest.type == MessageType.time) return false;
    return createdAt.difference(latest.createdAt).inMinutes.abs() >= 5;
  }

  void _insertTimeDividerIfNeeded(DateTime createdAt) {
    if (!_shouldInsertTimeDivider(createdAt)) return;
    messages.insert(
      0,
      MessageModel(
        id: 'time_${createdAt.millisecondsSinceEpoch}',
        conversationId: conversation.id,
        type: MessageType.time,
        content: _formatTimeLabel(createdAt),
        isSelf: false,
        createdAt: createdAt,
      ),
    );
  }

  String _formatTimeLabel(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(time.year, time.month, time.day);
    final hm =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    if (msgDay == today) return hm;
    if (msgDay == today.subtract(const Duration(days: 1))) return '昨天 $hm';
    return '${time.month}/${time.day} $hm';
  }

  Future<void> sendTextMessage() async {
    final text = inputText.value.trim();
    if (text.isEmpty) return;
    inputText.value = '';
    inputPanelMode.value = InputPanelMode.text;
    final now = DateTime.now();
    _insertTimeDividerIfNeeded(now);
    try {
      await _repository.sendText(_ref, text);
    } catch (e) {
      UiKitInitializer.toastError('发送失败');
    }
  }

  Future<void> sendImageMessage(String imagePath) async {
    inputPanelMode.value = InputPanelMode.text;
    _insertTimeDividerIfNeeded(DateTime.now());
    try {
      await _repository.sendImage(_ref, imagePath);
    } catch (e) {
      UiKitInitializer.toastError('图片发送失败');
    }
  }

  Future<void> sendCustomDemoCard() async {
    try {
      await _repository.sendCustom(
        _ref,
        ChatCustomMessageTypes.card,
        {
          'title': 'Demo 名片',
          'subtitle': '来自自定义消息',
        },
      );
    } catch (e) {
      UiKitInitializer.toastError('发送失败');
    }
  }

  void retrySend(MessageModel message) {
    if (message.sendStatus != MessageSendStatus.failed) return;
    if (message.type == MessageType.text) {
      inputText.value = message.content;
      sendTextMessage();
    }
  }

  void startRecordVoice() {
    isRecordingVoice.value = true;
    recordDurationSeconds.value = 0;
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordDurationSeconds.value++;
      if (recordDurationSeconds.value >= 60) {
        stopRecordVoice(send: true);
      }
    });
  }

  Future<void> stopRecordVoice({required bool send}) async {
    _recordTimer?.cancel();
    final duration = recordDurationSeconds.value.clamp(1, 60);
    isRecordingVoice.value = false;
    recordDurationSeconds.value = 0;
    if (!send || duration < 1) return;
    inputPanelMode.value = InputPanelMode.text;
    try {
      await _repository.sendVoice(_ref, 'voice_mock_$duration', duration);
    } catch (e) {
      UiKitInitializer.toastError('语音发送失败');
    }
  }

  void toggleVoicePlay(MessageModel message) {
    if (message.type != MessageType.voice) return;
    if (playingVoiceId.value == message.id) {
      _stopVoicePlay();
      return;
    }
    _stopVoicePlay();
    playingVoiceId.value = message.id;
    _voiceAnimFrame = 0;
    _voicePlayTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      _voiceAnimFrame = (_voiceAnimFrame + 1) % 3;
      voiceAnimFrame.value = _voiceAnimFrame;
    });
    Future.delayed(
      Duration(seconds: message.voiceDurationSeconds.clamp(1, 60)),
      _stopVoicePlay,
    );
  }

  void _stopVoicePlay() {
    _voicePlayTimer?.cancel();
    playingVoiceId.value = null;
    voiceAnimFrame.value = 0;
  }

  Future<void> copyMessage(MessageModel message) async {
    if (message.type != MessageType.text) return;
    await Clipboard.setData(ClipboardData(text: message.content));
    UiKitInitializer.toast('已复制');
  }

  Future<void> deleteMessage(MessageModel message) async {
    await _repository.deleteMessage(_ref, message.id);
    messages.removeWhere((m) => m.id == message.id);
    UiKitInitializer.toast('已删除');
  }

  Future<void> recallMessage(MessageModel message) async {
    if (!message.canRecall) {
      UiKitInitializer.toast('超过 $recallWindowMinutes 分钟，无法撤回');
      return;
    }
    try {
      await _repository.recallMessage(_ref, message.id);
      UiKitInitializer.toast('已撤回');
    } catch (error) {
      UiKitInitializer.toastError('撤回失败');
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String readStatusLabel(MessageModel message) {
    if (message.type == MessageType.time || message.type == MessageType.system) {
      return '';
    }
    if (!message.isSelf) {
      return message.readStatus == MessageReadStatus.read ? '已读' : '未读';
    }
    return switch (message.sendStatus) {
      MessageSendStatus.sending => '发送中',
      MessageSendStatus.failed => '发送失败',
      MessageSendStatus.success =>
        message.readStatus == MessageReadStatus.read ? '已读' : '未读',
    };
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    _voicePlayTimer?.cancel();
    _recordTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}