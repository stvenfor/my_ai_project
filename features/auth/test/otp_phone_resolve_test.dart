import 'package:flutter_test/flutter_test.dart';
import 'package:module_auth/user/controller/auth_controller.dart';

void main() {
  group('AuthController.resolveOtpVerifyPhone', () {
    test('rejects empty pending (restored form must not auto-bind)', () {
      expect(
        AuthController.resolveOtpVerifyPhone(
          pendingPhone: '',
          typedPhone: '13400000001',
        ),
        isNull,
      );
    });

    test('rejects typed phone that diverged from pending (串号根因)', () {
      expect(
        AuthController.resolveOtpVerifyPhone(
          pendingPhone: '13400000000',
          typedPhone: '13400000001',
        ),
        isNull,
      );
    });

    test('accepts matching pending + typed', () {
      expect(
        AuthController.resolveOtpVerifyPhone(
          pendingPhone: '13400000001',
          typedPhone: '13400000001',
        ),
        '13400000001',
      );
    });

    test('accepts pending when typed empty', () {
      expect(
        AuthController.resolveOtpVerifyPhone(
          pendingPhone: '13400000001',
          typedPhone: '',
        ),
        '13400000001',
      );
    });
  });
}
