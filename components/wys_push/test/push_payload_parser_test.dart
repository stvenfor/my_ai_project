import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wys_push/wys_push.dart';

void main() {
  group('PushPayloadParser', () {
    test('reads Harmony deep link from map extras', () {
      final event = PushPayloadParser.parse('onClickMessage', <String, dynamic>{
        'msgId': '123',
        'title': '消息',
        'content': '内容',
        'extras': <String, dynamic>{'url': 'tffanclub://com.sf.tf/homePaoPao'},
      });

      expect(event?.type, PushEventType.notificationOpened);
      expect(event?.notification?.id, 123);
      expect(event?.notification?.deeplink, 'tffanclub://com.sf.tf/homePaoPao');
    });

    test('decodes Harmony JSON-string extras', () {
      final event = PushPayloadParser.parse(
        'onArrivedMessage',
        <String, dynamic>{
          'extras': jsonEncode(<String, dynamic>{'deeplink': '/paopao'}),
        },
      );

      expect(event?.type, PushEventType.notificationArrived);
      expect(event?.notification?.extras, <String, dynamic>{
        'deeplink': '/paopao',
      });
      expect(event?.notification?.deeplink, '/paopao');
    });

    test('prefers the top-level deep link when present', () {
      final event = PushPayloadParser.parse('onClickMessage', <String, dynamic>{
        'deeplink': '/orders',
        'extras': <String, dynamic>{'url': '/paopao'},
      });

      expect(event?.notification?.deeplink, '/orders');
    });

    test('Harmony JMessage without extras yields empty deeplink (order push gap)', () {
      final event = PushPayloadParser.parse('onClickMessage', <String, dynamic>{
        'msgId': 'order-1',
        'title': '订单通知',
        'content': '您的订单已发货',
      });

      expect(event?.type, PushEventType.notificationOpened);
      expect(event?.notification?.deeplink, isNull);
    });

    test('Android-style order deeplink is preserved for routing', () {
      final event = PushPayloadParser.parse('onClickMessage', <String, dynamic>{
        'deeplink': 'tfapp://tf.com/orderList',
        'title': '订单通知',
        'content': '您的订单已发货',
      });

      expect(event?.notification?.deeplink, 'tfapp://tf.com/orderList');
    });

    test('reads deeplink nested under cn.jpush.android.EXTRA_EXTRA', () {
      final event = PushPayloadParser.parse(
        'onOpenNotification',
        <String, dynamic>{
          'title': '订单通知',
          'alert': '您的订单已发货',
          'extras': <String, dynamic>{
            'cn.jpush.android.EXTRA_EXTRA': <String, dynamic>{
              'deeplink': 'tfapp://tf.com/orderList',
            },
          },
        },
      );

      expect(event?.notification?.deeplink, 'tfapp://tf.com/orderList');
    });

    test('reads page from extras as deeplink candidate', () {
      final event = PushPayloadParser.parse('onClickMessage', <String, dynamic>{
        'extras': <String, dynamic>{'page': 'orderList'},
      });

      expect(event?.notification?.deeplink, 'orderList');
    });

    test('reads Harmony intent.url from extras', () {
      final event = PushPayloadParser.parse('onClickMessage', <String, dynamic>{
        'extras': <String, dynamic>{
          'intent': <String, dynamic>{
            'url': 'tfapp://tf.com/logisticsList',
          },
        },
      });

      expect(
        event?.notification?.deeplink,
        'tfapp://tf.com/logisticsList',
      );
    });

    test('ignores unsupported events and malformed extras', () {
      expect(
        PushPayloadParser.parse('unknown', const <String, dynamic>{}),
        isNull,
      );
      final event = PushPayloadParser.parse(
        'onCustomMessage',
        <String, dynamic>{'extras': '{invalid-json'},
      );
      expect(event?.message?.extras, isNull);
    });
  });
}
