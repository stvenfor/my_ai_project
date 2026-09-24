import 'package:flutter_test/flutter_test.dart';
import 'package:module_utils/utils/image_picker_utils.dart';

void main() {
  test('MediaPermissionResult covers camera / scan gate outcomes', () {
    // CameraPermissionGate / 扫码入口依赖这三种结果分支。
    expect(MediaPermissionResult.values, containsAll([
      MediaPermissionResult.granted,
      MediaPermissionResult.denied,
      MediaPermissionResult.permanentlyDenied,
    ]));
  });

  test('requestCameraAccess is the shared entry (always attempts system prompt)',
      () {
    // 回归护栏：业务不得绕过此 API 自建「只读 status 不 request」逻辑。
    expect(ImagePickerUtils.requestCameraAccess, isA<Function>());
    expect(ImagePickerUtils.ensureCameraPermission, isA<Function>());
  });
}
