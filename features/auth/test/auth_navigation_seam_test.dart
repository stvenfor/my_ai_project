import 'package:flutter_test/flutter_test.dart';
import 'package:module_auth/session/backend_auth_service.dart';
import 'package:module_core/core.dart';

void main() {
  tearDown(() {
    AuthLifecycle.inviteLoginHandler = null;
  });

  group('AuthLifecycle Invite Login seam', () {
    test('inviteLogin delegates to registered handler with redirect', () async {
      String? seen;
      AuthLifecycle.inviteLoginHandler = ({String? redirectRoute}) async {
        seen = redirectRoute;
      };

      await AuthLifecycle.inviteLogin(redirectRoute: '/home/used-car');
      expect(seen, '/home/used-car');
    });

    test('inviteLogin throws when handler not registered', () async {
      expect(
        () => AuthLifecycle.inviteLogin(),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('isLogoutSessionGone', () {
    test('treats invalid credentials and session-gone messages as Gone', () {
      expect(isLogoutSessionGone(const InvalidCredentialsFailure()), isTrue);
      expect(
        isLogoutSessionGone(const UnknownAuthFailure('会话不存在')),
        isTrue,
      );
      expect(isLogoutSessionGone(const SessionReplacedFailure()), isTrue);
      expect(isLogoutSessionGone(const SessionInvalidFailure()), isTrue);
      expect(
        isLogoutSessionGone(const NetworkAuthFailure()),
        isFalse,
      );
    });
  });
}
