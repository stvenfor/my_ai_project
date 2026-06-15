import 'package:flutter_test/flutter_test.dart';
import 'package:module_auth/session/auth_session.dart';

void main() {
  test('AuthSession 未注册时 isLoggedIn 为 false', () {
    expect(AuthSession.isLoggedIn, isFalse);
    expect(AuthSession.maybeService, isNull);
  });
}
