import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:module_auth/api/user_auth_api.dart';
import 'package:module_auth/session/backend_auth_service.dart';
import 'package:module_auth/session/device_auth_context.dart';
import 'package:module_core/core.dart';

/// In-memory [UserService] for Auth Session seam tests (no SP / Get registration).
class _FakeUserService extends UserService {
  @override
  final Rxn<User> currentUser = Rxn<User>();

  @override
  Future<void> setUser(User user) async {
    currentUser.value = user;
  }

  @override
  Future<void> clearUser() async {
    currentUser.value = null;
  }

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

/// Controllable [UserAuthApi] stub for BackendAuthService seam tests.
class _FakeUserAuthApi extends UserAuthApi {
  Object? refreshError;
  Object? logoutError;
  Object? registerError;
  Object? loginError;
  Object? sendOtpError;
  Object? verifyOtpError;

  RegisterResult? registerResult;
  LoginResult? loginResult;
  RefreshTokenResult? refreshResult;
  LoginResult? verifyOtpResult;

  int logoutCalls = 0;
  int refreshCalls = 0;
  int registerCalls = 0;
  int loginCalls = 0;
  int sendOtpCalls = 0;
  int verifyOtpCalls = 0;

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
    return refreshResult ??
        RefreshTokenResult(
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

  @override
  Future<RegisterResult> register({
    required String username,
    required String password,
    required String email,
    required String deviceId,
    required String platform,
  }) async {
    registerCalls++;
    final error = registerError;
    if (error != null) throw error;
    return registerResult ??
        const RegisterResult(
          user: BackendUser(id: 'u1', username: 'alice', email: 'a@b.com'),
          token: 'reg_token',
          refreshToken: 'reg_refresh',
          sessionId: 'reg_sess',
        );
  }

  @override
  Future<LoginResult> login({
    required String username,
    required String password,
    required String deviceId,
    required String platform,
  }) async {
    loginCalls++;
    final error = loginError;
    if (error != null) throw error;
    return loginResult ??
        LoginResult(
          token: 'login_token',
          refreshToken: 'login_refresh',
          sessionId: 'login_sess',
          user: BackendUser(
            id: 'u1',
            username: username.split('@').first,
            email: username,
          ),
        );
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    sendOtpCalls++;
    final error = sendOtpError;
    if (error != null) throw error;
  }

  @override
  Future<LoginResult> verifyPhoneOtp({
    required String phone,
    required String otp,
    required String deviceId,
    required String platform,
  }) async {
    verifyOtpCalls++;
    final error = verifyOtpError;
    if (error != null) throw error;
    return verifyOtpResult ??
        LoginResult(
          token: 'otp_token',
          refreshToken: 'otp_refresh',
          sessionId: 'otp_sess',
          user: BackendUser(
            id: 'otp-user',
            username: 'dev-$phone',
            email: '$phone@dev.test.local',
          ),
        );
  }
}

const _testDevice = DeviceAuthPayload(
  deviceId: 'test-device',
  platform: 'android',
);

User _loggedInUser({
  String token = 'access',
  String refreshToken = 'refresh',
  String sessionId = 'sess-1',
  String deviceId = 'test-device',
}) {
  return User(
    id: 'user-1',
    name: 'Alice',
    avatar: '',
    token: token,
    refreshToken: refreshToken,
    sessionId: sessionId,
    deviceId: deviceId,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeUserService userService;
  late _FakeUserAuthApi api;
  late BackendAuthService auth;

  setUp(() {
    userService = _FakeUserService();
    api = _FakeUserAuthApi();
    auth = BackendAuthService(
      userService,
      api: api,
      resolveDevice: () async => _testDevice,
    );
  });

  tearDown(() async {
    auth.onClose();
  });

  group('Cold Start Keep (ticket 01)', () {
    test('refresh failure keeps local Auth Session', () async {
      await userService.setUser(_loggedInUser());
      api.refreshError = const NetworkAuthFailure('connection timeout');

      await auth.refreshSession();

      expect(userService.isLoggedIn, isTrue);
      expect(userService.currentUser.value?.token, 'access');
      expect(userService.currentUser.value?.refreshToken, 'refresh');
      expect(api.refreshCalls, 1);
    });

    test('refresh success updates tokens without clearing session', () async {
      await userService.setUser(_loggedInUser());
      api.refreshResult = const RefreshTokenResult(
        token: 'rotated_access',
        refreshToken: 'rotated_refresh',
        sessionId: 'sess-2',
      );

      await auth.refreshSession();

      expect(userService.isLoggedIn, isTrue);
      expect(userService.currentUser.value?.token, 'rotated_access');
      expect(userService.currentUser.value?.refreshToken, 'rotated_refresh');
      expect(userService.currentUser.value?.sessionId, 'sess-2');
    });
  });

  group('Server-Confirmed Logout (ticket 02)', () {
    test('logout API success clears local Auth Session', () async {
      await userService.setUser(_loggedInUser());

      await auth.signOut();

      expect(userService.isLoggedIn, isFalse);
      expect(api.logoutCalls, 1);
      expect(auth.currentState, AuthSessionState.signedOut);
    });

    test('Gone (InvalidCredentialsFailure) clears local Auth Session', () async {
      await userService.setUser(_loggedInUser());
      api.logoutError = const InvalidCredentialsFailure();

      await auth.signOut();

      expect(userService.isLoggedIn, isFalse);
      expect(api.logoutCalls, 1);
    });

    test('Gone (session not found message) clears local Auth Session', () async {
      await userService.setUser(_loggedInUser());
      api.logoutError = const UnknownAuthFailure('session not found');

      await auth.signOut();

      expect(userService.isLoggedIn, isFalse);
    });

    test('network failure keeps local Auth Session and rethrows', () async {
      await userService.setUser(_loggedInUser());
      api.logoutError = const NetworkAuthFailure('无法连接服务端');

      await expectLater(auth.signOut(), throwsA(isA<NetworkAuthFailure>()));

      expect(userService.isLoggedIn, isTrue);
      expect(userService.currentUser.value?.token, 'access');
      expect(auth.currentState, isNot(AuthSessionState.signedOut));
    });

    test('non-Gone failure keeps local Auth Session and rethrows', () async {
      await userService.setUser(_loggedInUser());
      api.logoutError = const BackendServiceFailure('认证服务暂时不可用');

      await expectLater(auth.signOut(), throwsA(isA<BackendServiceFailure>()));

      expect(userService.isLoggedIn, isTrue);
    });
  });

  group('MockLocal logout (ticket 02)', () {
    test('MockAuthService signOut clears local without API', () async {
      final mockUsers = _FakeUserService();
      await mockUsers.setUser(_loggedInUser(token: 'mock_token'));
      final mock = MockAuthService(mockUsers);

      await mock.signOut();

      expect(mockUsers.isLoggedIn, isFalse);
      expect(mock.currentState, AuthSessionState.signedOut);
      mock.onClose();
    });
  });

  group('Registration Session In + Stay (ticket 05)', () {
    test('register with session tokens writes Auth Session (In)', () async {
      api.registerResult = const RegisterResult(
        user: BackendUser(id: 'u9', username: 'bob', email: 'bob@ex.com'),
        token: 'reg_access',
        refreshToken: 'reg_refresh',
        sessionId: 'reg_sess',
      );

      await auth.signUpWithEmail(
        email: 'bob@ex.com',
        password: 'secret12',
        displayName: 'bob',
      );

      expect(userService.isLoggedIn, isTrue);
      expect(userService.currentUser.value?.token, 'reg_access');
      expect(userService.currentUser.value?.id, 'u9');
      expect(api.registerCalls, 1);
      expect(api.loginCalls, 0);
    });

    test('register without token then signIn writes Auth Session (In)', () async {
      api.registerResult = const RegisterResult(
        user: BackendUser(id: 'u2', username: 'cara', email: 'cara@ex.com'),
      );
      api.loginResult = LoginResult(
        token: 'after_login',
        refreshToken: 'after_refresh',
        sessionId: 'after_sess',
        user: const BackendUser(
          id: 'u2',
          username: 'cara',
          email: 'cara@ex.com',
        ),
      );

      await auth.signUpWithEmail(
        email: 'cara@ex.com',
        password: 'secret12',
      );

      expect(userService.isLoggedIn, isTrue);
      expect(userService.currentUser.value?.token, 'after_login');
      expect(api.registerCalls, 1);
      expect(api.loginCalls, 1);
    });

    test('EmailAlreadyRegisteredFailure stays without writing session', () async {
      api.registerError = const EmailAlreadyRegisteredFailure();

      await expectLater(
        auth.signUpWithEmail(
          email: 'taken@ex.com',
          password: 'secret12',
        ),
        throwsA(isA<EmailAlreadyRegisteredFailure>()),
      );

      expect(userService.isLoggedIn, isFalse);
      expect(api.loginCalls, 0);
    });
  });

  group('Phone OTP (dev test number)', () {
    test('verifyPhoneOtp writes Auth Session', () async {
      await auth.verifyPhoneOtp(phone: '13400000000', otp: '123456');

      expect(userService.isLoggedIn, isTrue);
      expect(userService.currentUser.value?.token, 'otp_token');
      expect(api.verifyOtpCalls, 1);
      expect(auth.currentState, AuthSessionState.signedIn);
    });

    test('sendPhoneOtp forwards to API', () async {
      await auth.sendPhoneOtp(phone: '13400000000');
      expect(api.sendOtpCalls, 1);
    });

    test('verifyPhoneOtp surfaces InvalidOtpFailure without session', () async {
      api.verifyOtpError = const InvalidOtpFailure();

      await expectLater(
        auth.verifyPhoneOtp(phone: '13400000000', otp: '000000'),
        throwsA(isA<InvalidOtpFailure>()),
      );
      expect(userService.isLoggedIn, isFalse);
    });
  });
}
