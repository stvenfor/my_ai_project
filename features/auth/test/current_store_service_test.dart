import 'package:flutter_test/flutter_test.dart';
import 'package:module_auth/store/store_option.dart';

void main() {
  test('StoreOption keeps id/name for shared switch dialog', () {
    const a = StoreOption(id: '1', name: '[4S]北京沃德龙鼎吉利');
    const b = StoreOption(id: '2', name: '[4S]北京腾远吉利');
    expect(a.id, '1');
    expect(b.name, contains('腾远'));
    expect(<StoreOption>[a, b].map((e) => e.id).toList(), ['1', '2']);
  });
}
