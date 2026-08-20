import 'package:flutter_test/flutter_test.dart';
import 'package:wys_common/wys_common.dart';

void main() {
  group('WysPhoneAccountUtils', () {
    test('CN mobile +86 accepts 11-digit national', () {
      expect(WysPhoneAccountUtils.isValidPhone('+86', '13800138000'), isTrue);
      expect(
        WysPhoneAccountUtils.fullPhoneE164('+86', '13800138000'),
        '+8613800138000',
      );
      expect(
        WysPhoneAccountUtils.phoneForMsgSend('+86', '13800138000'),
        '13800138000',
      );
    });

    test('CN rejects too-short national', () {
      expect(WysPhoneAccountUtils.isValidPhone('+86', '12345'), isFalse);
      expect(WysPhoneAccountUtils.fullPhoneE164('+86', '12345'), isNull);
    });

    test('US mobile with +1', () {
      expect(WysPhoneAccountUtils.isValidPhone('+1', '2025550123'), isTrue);
      expect(
        WysPhoneAccountUtils.fullPhoneE164('+1', '2025550123'),
        '+12025550123',
      );
      expect(
        WysPhoneAccountUtils.phoneForMsgSend('+1', '2025550123'),
        '+12025550123',
      );
    });

    test('invalid calling code fails', () {
      expect(WysPhoneAccountUtils.isValidPhone('+999', '13800138000'), isFalse);
    });

    test('strips leading 0 on national', () {
      expect(
        WysPhoneAccountUtils.fullPhoneE164('+33', '0655570576'),
        '+33655570576',
      );
    });

    test('empty phone fails', () {
      expect(WysPhoneAccountUtils.isValidPhone('+86', ''), isFalse);
      expect(WysPhoneAccountUtils.isValidPhone('+86', '   '), isFalse);
    });
  });
}
