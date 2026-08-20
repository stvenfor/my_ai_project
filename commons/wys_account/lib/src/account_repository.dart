import 'dart:async';

import 'mock/mock_account_session.dart';
import 'models/account_user.dart';
import 'session/account_session_store.dart';

/// 账号中心：内存态 + 本地缓存 + 变更通知。
class AccountRepository {
  AccountRepository._(this._store);

  static AccountRepository? _instance;
  static bool _initialized = false;

  final AccountSessionStore _store;
  AccountUser? _current;
  final _authController = StreamController<AccountUser?>.broadcast();

  /// 登录态变更（含登出为 null）。各 module 可 listen 刷新 UI。
  Stream<AccountUser?> get authStateChanges => _authController.stream;

  static Future<void> ensureInitialized({bool? enableMockSession}) async {
    if (_initialized) return;
    final store = await AccountSessionStore.create();
    _instance = AccountRepository._(store);
    _instance!._current = store.readUser();
    if (_instance!._current != null && !_instance!.isLoggedIn) {
      _instance!._current = null;
      await store.clear();
    }
    final useMock = enableMockSession ?? MockAccountSession.enabled;
    if (!useMock && MockAccountSession.isMock(_instance!._current)) {
      _instance!._current = null;
      await store.clear();
    }
    if (useMock && _instance!._current == null) {
      _instance!._current = MockAccountSession.user;
      await store.writeUser(_instance!._current);
    }
    _initialized = true;
  }

  static AccountRepository get instance {
    if (!_initialized || _instance == null) {
      throw StateError(
        'WysAccount 未初始化，请在 main() 中调用 await WysAccount.initialize()',
      );
    }
    return _instance!;
  }

  /// 是否已登录（有有效 token）。
  bool get isLoggedIn => _current?.hasValidToken ?? false;

  /// 当前用户；未登录为 null。
  AccountUser? get currentUser => _current;

  String? get token => _current?.token;

  String? get userId => _current?.userId;

  /// 登录成功或刷新资料后调用（如 module_login）。
  Future<void> setSession(AccountUser user) async {
    if (!user.hasValidToken) {
      throw ArgumentError('AccountUser 需要有效 token');
    }
    _current = user;
    await _store.writeUser(user);
    _authController.add(_current);
  }

  /// 仅更新展示字段，token 不变。
  Future<void> updateProfile({
    String? nickname,
    String? avatarUrl,
    String? phone,
    Map<String, dynamic>? extra,
  }) async {
    final cur = _current;
    if (cur == null) return;
    final next = cur.copyWith(
      nickname: nickname,
      avatarUrl: avatarUrl,
      phone: phone,
      extra: extra ?? cur.extra,
    );
    await setSession(next);
  }

  Future<void> logout() async {
    _current = null;
    await _store.clear();
    _authController.add(null);
  }

  void dispose() {
    _authController.close();
  }
}
