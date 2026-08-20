/// 推送通知消息模型，对齐安卓 `NotificationMessage`。
class PushNotification {
  const PushNotification({
    this.id,
    this.title,
    this.content,
    this.extras,
    this.deeplink,
  });

  /// 通知 ID
  final int? id;

  /// 通知标题
  final String? title;

  /// 通知内容
  final String? content;

  /// 附加字段
  final Map<String, dynamic>? extras;

  /// 深链接
  final String? deeplink;

  factory PushNotification.fromMap(Map<String, dynamic> map) {
    return PushNotification(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      title: map['title']?.toString(),
      content: map['content']?.toString(),
      extras: map['extras'] is Map
          ? Map<String, dynamic>.from(map['extras'] as Map)
          : null,
      deeplink: map['deeplink']?.toString(),
    );
  }
}

/// 自定义消息模型，对齐安卓 `CustomMessage`。
class PushCustomMessage {
  const PushCustomMessage({
    this.title,
    this.content,
    this.extras,
  });

  final String? title;
  final String? content;
  final Map<String, dynamic>? extras;

  factory PushCustomMessage.fromMap(Map<String, dynamic> map) {
    return PushCustomMessage(
      title: map['title']?.toString(),
      content: map['content']?.toString(),
      extras: map['extras'] is Map
          ? Map<String, dynamic>.from(map['extras'] as Map)
          : null,
    );
  }
}

/// 推送事件类型，对齐安卓 `JPushMessageReceiver` 回调。
enum PushEventType {
  /// 收到通知（对应 `onNotifyMessageArrived`）
  notificationArrived,

  /// 点击通知打开（对应 `onNotifyMessageOpened`）
  notificationOpened,

  /// 收到自定义消息（对应 `onMessage`）
  customMessage,
}

/// 推送事件
class PushEvent {
  const PushEvent({
    required this.type,
    this.notification,
    this.message,
  });

  final PushEventType type;
  final PushNotification? notification;
  final PushCustomMessage? message;
}
