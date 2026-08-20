import 'package:flutter_test/flutter_test.dart';
import 'package:wys_login_share_pay/wys_login_share_pay.dart';

void main() {
  group('WysWechatPayParams', () {
    test('maps lowercase server fields', () {
      final params = WysWechatPayParams.fromMap({
        'appid': 'app',
        'partnerid': 'partner',
        'prepayid': 'prepay',
        'package': 'Sign=WXPay',
        'noncestr': 'nonce',
        'timestamp': '123',
        'sign': 'signature',
      });

      expect(params.appId, 'app');
      expect(params.partnerId, 'partner');
      expect(params.timestamp, 123);
      expect(params.isValid, isTrue);
    });

    test('maps camelCase server fields', () {
      final params = WysWechatPayParams.fromMap({
        'appId': 'app',
        'partnerId': 'partner',
        'prepayId': 'prepay',
        'packageValue': 'Sign=WXPay',
        'nonceStr': 'nonce',
        'timeStamp': 456,
        'sign': 'signature',
      });

      expect(params.prepayId, 'prepay');
      expect(params.packageValue, 'Sign=WXPay');
      expect(params.timestamp, 456);
      expect(params.isValid, isTrue);
    });

    test('rejects incomplete fields', () {
      expect(WysWechatPayParams.fromMap(const {}).isValid, isFalse);
    });
  });

  test('maps SDK result codes', () {
    expect(WysWechatResult.fromSdkCode(0).status, WysWechatStatus.success);
    expect(WysWechatResult.fromSdkCode(-2).status, WysWechatStatus.cancelled);
    expect(WysWechatResult.fromSdkCode(-1).status, WysWechatStatus.sdkError);
  });
}
