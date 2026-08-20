import 'package:flutter_test/flutter_test.dart';
import 'package:wys_common/wys_common.dart';

void main() {
  group('WysCallingCodeRepository.parseCallingCodes', () {
    test('prefers codePlus and normalizes +', () {
      final list = WysCallingCodeRepository.parseCallingCodes({
        'names': ['中国', '美国'],
        'code': ['86', '1'],
        'codePlus': ['+86', '1'],
      });
      expect(list.map((e) => e.name).toList(), ['中国', '美国']);
      expect(list.map((e) => e.code).toList(), ['+86', '+1']);
    });

    test('falls back to code when codePlus missing', () {
      final list = WysCallingCodeRepository.parseCallingCodes({
        'names': ['中国'],
        'code': ['86'],
      });
      expect(list.single.name, '中国');
      expect(list.single.code, '+86');
    });

    test('returns empty on invalid body', () {
      expect(WysCallingCodeRepository.parseCallingCodes(null), isEmpty);
      expect(WysCallingCodeRepository.parseCallingCodes([]), isEmpty);
      expect(
        WysCallingCodeRepository.parseCallingCodes({'names': null}),
        isEmpty,
      );
    });
  });
}
