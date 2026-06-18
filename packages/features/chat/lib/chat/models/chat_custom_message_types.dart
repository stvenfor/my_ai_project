import 'package:module_chat/chat/models/message_type.dart';

/// 业务自定义消息类型（融云 CustomMessage）。
class ChatCustomMessageTypes {
  ChatCustomMessageTypes._();

  static const card = 'biz.card';
  static const order = 'biz.order';
  static const liveShare = 'biz.live_share';
}

extension MessageTypePreview on MessageType {
  String get listPreview => switch (this) {
        MessageType.text => '',
        MessageType.image => '[图片]',
        MessageType.voice => '[语音]',
        MessageType.custom => '[自定义消息]',
        MessageType.system => '',
        MessageType.time => '',
      };
}
