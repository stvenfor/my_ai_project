import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:module_auth/api/user_auth_api.dart';
import 'package:module_auth/session/backend_auth_service.dart';
import 'package:module_auth/session/device_auth_context.dart';
import 'package:module_auth/session/session_guard.dart';
import 'package:module_core/core.dart';

class _FakeUserService extends UserService {
  @override
  final Rxn<User> currentUser = Rxn<User>();

  @override
  Future<void> setUser(User user) async => currentUser.value = user;

  @override
  Future<void> clearUser() async => currentUser.value = null;

  @override
  Future<void> updateAuthTokens({
    required String token,
    required String refreshToken,
    String? sessionId,
  }) async {
    final user = currentUser.value;
    if (user == null) return;
    await setUser(
      user.copyWith(
        token: token,
        refreshToken: refreshToken,
        sessionId: sessionId?.isNotEmpty == true ? sessionId : user.sessionId,
      ),
    );
  }
}

class _FakeUserAuthApi extends UserAuthApi {
  Object? refreshError;
  Object? logoutError;
  int refreshCalls = 0;
  int logoutCalls = 0;

  @override
  Future<RefreshTokenResult> refresh({
    required String refreshToken,
    String? deviceId,
    String? sessionId,
    String? platform,
  }) async {
    refreshCalls++;
    final error = refreshError;
    if (error != null) throw error;
    return RefreshTokenResult(
      token: 'new_access',
      refreshToken: 'new_refresh',
      sessionId: sessionId ?? 'sess',
    );
  }

  @override
  Future<void> logout({
    required String token,
    required String sessionId,
    required String deviceId,
  }) async {
    logoutCalls++;
    final error = logoutError;
    if (error != null) throw error;
  }
}

User _loggedInUser() => const User(
      id: 'u1',
      name: 'alice',
      avatar: '',
      token: 'access',
      refreshToken: 'refresh',
      sessionId: 'sess-old',
      deviceId: 'device-a',
    );

void main() {
  late _FakeUserService userService;
  late _FakeUserAuthApi api;
  late BackendAuthService auth;

  setUp(() async {
    Get.reset();
    userService = _FakeUserService();
    api = _FakeUserAuthApi();
    auth = BackendAuthService(
      userService,
      api: api,
      resolveDevice: () async => const DeviceAuthPayload(
        deviceId: 'device-a',
        platform: 'ios',
      ),
    );
    Get.put<UserService>(userService);
    Get.put<AuthService>(auth);
    await userService.setUser(_loggedInUser());
  });

  tearDown(() {
    auth.onClose();
    Get.reset();
  });

  group('session force-logout by AuthBizCode', () {
    test('isLogoutSessionGone treats typed session failures as Gone', () {
      expect(isLogoutSessionGone(const SessionReplacedFailure()), isTrue);
      expect(isLogoutSessionGone(const SessionInvalidFailure()), isTrue);
      expect(isLogoutSessionGone(const NetworkAuthFailure()), isFalse);
    });

    test('refreshSession rethrows SessionReplacedFailure', () async {
      api.refreshError = const SessionReplacedFailure();

      await expectLater(
        auth.refreshSession(),
        throwsA(isA<SessionReplacedFailure>()),
      );
      expect(api.refreshCalls, 1);
      expect(userService.isLoggedIn, isTrue);
    });

    test('shouldForceLogout matches Go codes 10021/10022', () {
      expect(
        SessionGuardHook.shouldForceLogout(code: AuthBizCode.sessionReplaced),
        isTrue,
      );
      expect(
        SessionGuardHook.shouldForceLogout(code: AuthBizCode.sessionInvalid),
        isTrue,
      );
      expect(
        SessionGuardHook.shouldTryTokenRefresh(
          code: AuthBizCode.sessionReplaced,
        ),
        isFalse,
      );
      expect(
        SessionGuardHook.shouldForceLogout(code: AuthBizCode.unauthorized),
        isFalse,
      );
    });

    test('extractCode reads ResultModel envelope', () {
      expect(
        SessionGuardHook.extractCode({
          'code': 10021,
          'message': '账号已在其他设备登录，请重新登录',
          'data': <String, dynamic>{},
        }),
        AuthBizCode.sessionReplaced,
      );
    });

    test('manual signOut on SessionReplaced clears local Auth Session',
        () async {
      api.logoutError = const SessionReplacedFailure();

      await auth.signOut();

      expect(userService.isLoggedIn, isFalse);
      expect(api.logoutCalls, 1);
    });
  });
}
