import 'package:flutter_test/flutter_test.dart';
import 'package:module_utils/module_utils.dart';

void main() {
  test('MediaPickSource 包含相册与相机', () {
    expect(MediaPickSource.values, contains(MediaPickSource.gallery));
    expect(MediaPickSource.values, contains(MediaPickSource.camera));
  });
}
