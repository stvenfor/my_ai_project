/// H5 ↔ Flutter 桥接消息体。
class WebMessage {
  const WebMessage({
    required this.action,
    this.payload,
  });

  final String action;
  final Map<String, dynamic>? payload;

  factory WebMessage.fromDynamic(dynamic raw) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      return WebMessage(
        action: map['action']?.toString() ?? '',
        payload: map['payload'] is Map
            ? Map<String, dynamic>.from(map['payload'] as Map)
            : null,
      );
    }
    return const WebMessage(action: '');
  }

  Map<String, dynamic> toJson() => {
        'action': action,
        if (payload != null) 'payload': payload,
      };
}

/// 桥接 action 处理函数，返回 JSON 可序列化对象供 H5 使用。
typedef WebBridgeHandler = Future<dynamic> Function(WebMessage message);
