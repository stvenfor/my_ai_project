import 'dart:convert';

import 'push_event.dart';

/// Converts platform-specific JPush callback payloads into common events.
class PushPayloadParser {
  PushPayloadParser._();

  static PushEvent? parse(String eventName, dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    final type = _eventType(eventName);
    if (type == null) return null;

    final extras = _flattenExtras(_decodeExtras(map['extras'] ?? map['extra']));
    final deeplink = _firstNonEmptyString(<dynamic>[
      map['deeplink'],
      map['url'],
      map['route'],
      map['uri'],
      extras?['deeplink'],
      extras?['url'],
      extras?['route'],
      extras?['uri'],
      extras?['page'],
      extras?['path'],
      // HarmonyOS / 服务端常见：extras.intent.url = tfapp://tf.com/...
      _intentUrl(extras?['intent']),
    ]);

    return PushEvent(
      type: type,
      notification: PushNotification(
        id: _parseId(map['msgId'] ?? map['id']),
        title: map['title']?.toString(),
        content: _firstNonEmptyString(<dynamic>[
          map['content'],
          map['message'],
          map['alert'],
        ]),
        extras: extras,
        deeplink: deeplink,
      ),
      message: type == PushEventType.customMessage
          ? PushCustomMessage(
              title: map['title']?.toString(),
              content: _firstNonEmptyString(<dynamic>[
                map['content'],
                map['message'],
              ]),
              extras: extras,
            )
          : null,
    );
  }

  static PushEventType? _eventType(String eventName) => switch (eventName) {
    'onArrivedMessage' ||
    'onReceiveNotification' => PushEventType.notificationArrived,
    'onClickMessage' ||
    'onOpenNotification' => PushEventType.notificationOpened,
    'onCustomMessage' || 'onReceiveMessage' => PushEventType.customMessage,
    _ => null,
  };

  static Map<String, dynamic>? _decodeExtras(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is! String || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  /// Android JPush extras 常把自定义字段嵌在 `cn.jpush.android.EXTRA_EXTRA`。
  static Map<String, dynamic>? _flattenExtras(Map<String, dynamic>? extras) {
    if (extras == null) return null;
    final flat = Map<String, dynamic>.from(extras);
    final nested = extras['cn.jpush.android.EXTRA_EXTRA'] ??
        extras['cn.jpush.android.E'];
    final nestedMap = _decodeExtras(nested);
    if (nestedMap != null) {
      flat.addAll(nestedMap);
    }
    return flat;
  }

  static String? _intentUrl(dynamic intent) {
    if (intent is String && intent.trim().isNotEmpty) return intent.trim();
    if (intent is Map) {
      return _firstNonEmptyString(<dynamic>[
        intent['url'],
        intent['uri'],
        intent['deeplink'],
      ]);
    }
    return null;
  }

  static int? _parseId(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString().replaceFirst('local_', '') ?? '');
  }

  static String? _firstNonEmptyString(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }
}
