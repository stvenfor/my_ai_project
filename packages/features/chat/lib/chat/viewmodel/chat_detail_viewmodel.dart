import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:module_chat/chat/models/conversation_model.dart';
import 'package:module_chat/chat/models/message_model.dart';
import 'package:module_chat/chat/models/message_read_status.dart';
import 'package:module_chat/chat/models/message_send_status.dart';
import 'package:module_chat/chat/models/message_type.dart';
import 'package:module_chat/chat/repository/chat_repository.dart';
import 'package:module_chat/chat/repository/mock_chat_repository.dart';
import 'package:module_common_ui/module_common_ui.dart';
import 'package:module_utils/module_utils.dart';

enum InputPanelMode { text, voice, emoji, more }

class ChatDetailViewModel extends GetxController {
  ChatDetailViewModel({
    required this.conversation,
    ChatRepository? repository,
  }) : _repository = repository ?? MockChatRepository.instance;

  final ConversationModel conversation;
  final ChatRepository _repository;

  final messages = <MessageModel>[].obs;
  final inputText = ''.obs;
  final inputPanelMode = InputPanelMode.text.obs;
  final isLoading = false.obs;
  final playingVoiceId = RxnString();
  final isRecordingVoice = false.obs;
  final recordDurationSeconds = 0.obs;

  final scrollController = ScrollController();
  Timer? _mockReplyTimer;
  Timer? _voicePlayTimer;
  Timer? _recordTimer;
  int _voiceAnimFrame = 0;
  final voiceAnimFrame = 0.obs;
  int _messageSeq = 0;

  static const recallWindowMinutes = 3;
  static const emojiList = [
    '😀', '😂', '🥰', '😎', '🤔', '👍', '🙏', '🎉',
    '❤️', '🔥', '👋', '😭', '🤣', '😊', '🥳', '💪',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
    _scheduleMockReply();
  }

  Future<void> _loadMessages() async {
    isLoading.value = true;
    try {
      final list = await _repository.fetchMessages(conversation.id);
      messages.assignAll(list);
      await _markPeerMessagesRead();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _markPeerMessagesRead() async {
    final unreadIds = messages
        .where((m) => !m.isSelf && m.readStatus == MessageReadStatus.unread)
        .map((m) => m.id)
        .toList();
    if (unreadIds.isEmpty) return;
    await _repository.markMessagesRead(conversation.id, unreadIds);
    for (var i = 0; i < messages.length; i++) {
      if (unreadIds.contains(messages[i].id)) {
        messages[i] =
            messages[i].copyWith(readStatus: MessageReadStatus.read);
      }
    }
  }

  void updateInput(String value) => inputText.value = value;

  void toggleVoiceInput() {
    if (inputPanelMode.value == InputPanelMode.voice) {
      inputPanelMode.value = InputPanelMode.text;
    } else {
      inputPanelMode.value = InputPanelMode.voice;
    }
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

  String _nextMessageId() {
    _messageSeq++;
    return 'local_${DateTime.now().millisecondsSinceEpoch}_$_messageSeq';
  }

  bool _shouldInsertTimeDivider(DateTime createdAt) {
    if (messages.isEmpty) return true;
    final latest = messages.first;
    if (latest.type == MessageType.time) return false;
    return createdAt.difference(latest.createdAt).inMinutes.abs() >= 5;
  }

  void _insertTimeDividerIfNeeded(DateTime createdAt) {
    if (!_shouldInsertTimeDivider(createdAt)) return;
    final divider = MessageModel(
      id: _nextMessageId(),
      conversationId: conversation.id,
      type: MessageType.time,
      content: _formatTimeLabel(createdAt),
      isSelf: false,
      createdAt: createdAt,
    );
    messages.insert(0, divider);
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
    await _sendMessage(
      type: MessageType.text,
      content: text,
    );
  }

  Future<void> sendImageMessage(String imagePath) async {
    inputPanelMode.value = InputPanelMode.text;
    await _sendMessage(
      type: MessageType.image,
      content: imagePath,
    );
  }

  Future<void> _sendMessage({
    required MessageType type,
    required String content,
    int voiceDurationSeconds = 0,
  }) async {
    final now = DateTime.now();
    _insertTimeDividerIfNeeded(now);

    final pending = MessageModel(
      id: _nextMessageId(),
      conversationId: conversation.id,
      type: type,
      content: content,
      isSelf: true,
      createdAt: now,
      sendStatus: MessageSendStatus.sending,
      readStatus: MessageReadStatus.unread,
      voiceDurationSeconds: voiceDurationSeconds,
    );
    messages.insert(0, pending);
    _scrollToLatest();

    try {
      final saved = await _repository.sendMessage(pending);
      final index = messages.indexWhere((m) => m.id == pending.id);
      if (index >= 0) {
        messages[index] = saved.copyWith(readStatus: MessageReadStatus.read);
      }
      // 模拟对方已读
      Future.delayed(const Duration(seconds: 2), () {
        final idx = messages.indexWhere((m) => m.id == saved.id);
        if (idx >= 0) {
          messages[idx] = messages[idx].copyWith(
            readStatus: MessageReadStatus.read,
          );
        }
      });
    } catch (error) {
      LogUtils.e('[Chat] send failed: $error');
      final index = messages.indexWhere((m) => m.id == pending.id);
      if (index >= 0) {
        messages[index] =
            messages[index].copyWith(sendStatus: MessageSendStatus.failed);
      }
      UiKitInitializer.toastError('发送失败，请重试');
    }
  }

  Future<void> receiveMessage(MessageModel message) async {
    _insertTimeDividerIfNeeded(message.createdAt);
    messages.insert(0, message);
    _scrollToLatest();
    await _repository.sendMessage(message);
  }

  void mockReceiveMessage() {
    final replies = [
      '好的，没问题 👌',
      '收到！',
      '稍等一下',
      '哈哈哈',
      '[自动回复] 我在忙，稍后联系你',
    ];
    final text = replies[Random().nextInt(replies.length)];
    final msg = MessageModel(
      id: _nextMessageId(),
      conversationId: conversation.id,
      type: MessageType.text,
      content: text,
      isSelf: false,
      createdAt: DateTime.now(),
      readStatus: MessageReadStatus.unread,
    );
    receiveMessage(msg);
  }

  void _scheduleMockReply() {
    _mockReplyTimer?.cancel();
    _mockReplyTimer = Timer(const Duration(seconds: 8), () {
      if (!Get.isRegistered<ChatDetailViewModel>()) return;
      mockReceiveMessage();
    });
  }

  void retrySend(MessageModel message) {
    if (message.sendStatus != MessageSendStatus.failed) return;
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index < 0) return;
    messages[index] =
        messages[index].copyWith(sendStatus: MessageSendStatus.sending);
    _repository.sendMessage(message).then((saved) {
      messages[index] = saved.copyWith(readStatus: MessageReadStatus.read);
    }).catchError((_) {
      messages[index] =
          messages[index].copyWith(sendStatus: MessageSendStatus.failed);
      UiKitInitializer.toastError('重试失败');
    });
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
    await _sendMessage(
      type: MessageType.voice,
      content: 'voice_mock',
      voiceDurationSeconds: duration,
    );
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
    await _repository.deleteMessage(conversation.id, message.id);
    messages.removeWhere((m) => m.id == message.id);
    UiKitInitializer.toast('已删除');
  }

  Future<void> recallMessage(MessageModel message) async {
    if (!message.canRecall) {
      UiKitInitializer.toast('超过 ${recallWindowMinutes} 分钟，无法撤回');
      return;
    }
    try {
      final systemMsg =
          await _repository.recallMessage(conversation.id, message.id);
      final index = messages.indexWhere((m) => m.id == message.id);
      if (index >= 0) messages[index] = systemMsg;
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
    _mockReplyTimer?.cancel();
    _voicePlayTimer?.cancel();
    _recordTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}
