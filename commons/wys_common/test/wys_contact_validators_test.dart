import 'package:flutter_test/flutter_test.dart';
import 'package:wys_common/wys_common.dart';

void main() {
  group('WysContactValidators.isNameValid', () {
    test('empty rejected', () {
      expect(WysContactValidators.isNameValid(''), isFalse);
      expect(WysContactValidators.isNameValid('   '), isFalse);
    });

    test('within 12 accepted', () {
      expect(WysContactValidators.isNameValid('张三'), isTrue);
      expect(WysContactValidators.isNameValid('一二三四五六七八九十廿二'), isTrue);
    });

    test('over 12 rejected', () {
      expect(
        WysContactValidators.isNameValid('一二三四五六七八九十廿二超'),
        isFalse,
      );
    });
  });

  group('WysContactValidators.isCnMobile', () {
    test('valid 11-digit starting with 1', () {
      expect(WysContactValidators.isCnMobile('13800138000'), isTrue);
      expect(WysContactValidators.isCnMobile('138-0013-8000'), isTrue);
    });

    test('rejects wrong prefix / length', () {
      expect(WysContactValidators.isCnMobile('23800138000'), isFalse);
      expect(WysContactValidators.isCnMobile('1380013800'), isFalse);
      expect(WysContactValidators.isCnMobile('138001380001'), isFalse);
      expect(WysContactValidators.isCnMobile(''), isFalse);
    });
  });
}
