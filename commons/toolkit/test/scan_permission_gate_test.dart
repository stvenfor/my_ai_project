import 'package:flutter_test/flutter_test.dart';
import 'package:module_utils/utils/image_picker_utils.dart';

void main() {
  test('MediaPermissionResult covers scan gate outcomes', () {
    // 首页扫码入口依赖这三种结果分支，缺一则权限失败会静默。
    expect(MediaPermissionResult.values, containsAll([
      MediaPermissionResult.granted,
      MediaPermissionResult.denied,
      MediaPermissionResult.permanentlyDenied,
    ]));
  });
}
